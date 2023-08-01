import {
  canAccessDeployment,
  getAllDocuments,
  getDocsByField,
  saveDocument,
  updateByField,
} from "@/utils/Api_SeverSideCon"
import { getBuildStatus, mergeVariables, pushPubSubMsg } from "@/utils/api"
import { envOrFail } from "@/utils/env"
import { withAuth } from "@/utils/middleware"
import {
  AuthedNextApiHandler,
  DEPLOYMENT_ACTIONS,
  DEPLOYMENT_STATUS,
  IBuild,
  IDeployment,
  IPubSubMsg,
} from "@/utils/types"
import { Timestamp } from "firebase-admin/firestore"
import { NextApiResponse } from "next"
import { v4 as uuidv4 } from "uuid"

const gcpProjectId = envOrFail(
  "NEXT_PUBLIC_GCP_PROJECT_ID",
  process.env.NEXT_PUBLIC_GCP_PROJECT_ID,
)

const createDeployment = async (
  req: AuthedNextApiHandler,
  res: NextApiResponse,
) => {
  const body = req.body
  const uuid = uuidv4()
  body.deploymentId = uuid.split("-")[0]?.substring(0, 4)
  const moduleName = body.module.replace(/_/g, "-")
  body.projectId = body.variables.project_id_prefix
    ? `${body.variables.project_id_prefix}-${body.deploymentId}`
    : `radlab-${moduleName}-${body.deploymentId}`
  const { billingId, variables } = await mergeVariables(body)

  body.variables = variables
  body.builds = []
  // @ts-ignore
  const response: IDeployment = await saveDocument("deployments", body)
  if (!response) {
    return res.status(500).json({ message: "Internal Server Error" })
  }

  const pubSubData: IPubSubMsg = {
    module: response.module,
    deploymentId: body.deploymentId,
    projectId: gcpProjectId,
    action: DEPLOYMENT_ACTIONS.CREATE,
    user: body.deployedByEmail,
    variables: {
      ...variables,
      billing_account_id: billingId,
      deployment_id: body.deploymentId,
    },
  }

  delete pubSubData.variables.resource_creator_identity

  try {
    await pushPubSubMsg(pubSubData)
  } catch (error) {
    console.error(error)
  }

  return res.status(200).json({ response })
}

const getDeployments = async (
  req: AuthedNextApiHandler,
  res: NextApiResponse,
) => {
  const { isAdmin, email } = req.user

  if (!email) {
    return res.status(401).json({ message: "Unauthorized" })
  }

  const deployments = (await getAllDocuments("deployments")) as IDeployment[]
  const possiblyStaleDeployments = deployments
    .filter((deployment) => {
      return (
        deployment.status &&
        deployment.builds?.length &&
        [
          DEPLOYMENT_STATUS.QUEUED,
          DEPLOYMENT_STATUS.WORKING,
          DEPLOYMENT_STATUS.PENDING,
        ].includes(deployment.status)
      )
    })
    .filter((deployment) => canAccessDeployment(deployment, email, isAdmin))

  if (!possiblyStaleDeployments.length) {
    return res.status(200).json({ deployments })
  }

  const getBuilds: Promise<any>[] = []
  possiblyStaleDeployments.forEach((deployment: IDeployment) => {
    const mostRecentBuild =
      deployment.builds &&
      deployment.builds.sort(
        (a: IBuild, b: IBuild) => b.createdAt._seconds - a.createdAt._seconds,
      )[0]
    mostRecentBuild &&
      getBuilds.push(
        getBuildStatus(mostRecentBuild.buildId, deployment.deploymentId),
      )
  })

  let updateDoc: Promise<any>[] = []
  await Promise.all(getBuilds).then((cloudBuildRes: any) => {
    cloudBuildRes.forEach((cloudBuild: any) => {
      const updateData = {
        status: cloudBuild.status,
      }
      updateDoc.push(
        updateByField(
          "deployments",
          "deploymentId",
          cloudBuild.deploymentId,
          updateData,
        ),
      )
    })
  })

  await Promise.all(updateDoc)

  const deploymentsList = (await getAllDocuments(
    "deployments",
  )) as IDeployment[]

  return res.status(200).json({
    deployments: deploymentsList.filter((deployment) =>
      canAccessDeployment(deployment, email, isAdmin),
    ),
  })
}

const getDeploymentsByEmail = async (
  req: AuthedNextApiHandler,
  res: NextApiResponse,
  deployedByEmail: string,
) => {
  const { isAdmin, email } = req.user

  if (!isAdmin && email !== deployedByEmail) {
    return res.status(403).json({ message: "Forbidden" })
  }

  const deployments = (await getDocsByField(
    "deployments",
    "deployedByEmail",
    deployedByEmail,
  )) as IDeployment[]

  return res.status(200).json({ deployments })
}

const deleteDeployment = async (
  req: AuthedNextApiHandler,
  res: NextApiResponse,
) => {
  const body = req.body
  const deploymentIds = body.deploymentIds as string[] | undefined

  if (!deploymentIds || !deploymentIds.length) {
    return res.status(400).send("Missing deploymentIds from body")
  }

  deploymentIds.forEach(async (deploymentId) => {
    // @ts-ignore
    const [deployment] = (await getDocsByField(
      "deployments",
      "deploymentId",
      deploymentId,
    )) as IDeployment[]

    if (!deployment) {
      return res.status(400).json({ message: "Not found" })
    }

    const pubSubData: IPubSubMsg = {
      module: deployment.module,
      deploymentId,
      projectId: gcpProjectId,
      action: DEPLOYMENT_ACTIONS.DELETE,
      user: body.deployedByEmail,
      variables: {
        module_name: deployment.module,
        deployment_id: deploymentId,
      },
    }

    delete pubSubData.variables.resource_creator_identity
    try {
      await pushPubSubMsg(pubSubData)
      const now = Timestamp.now()
      deployment.deletedAt = {
        _seconds: now.seconds,
        _nanoseconds: now.nanoseconds,
      }
      await updateByField(
        "deployments",
        "deploymentId",
        deploymentId,
        deployment,
      )
    } catch (error) {
      return res.status(500).json({ message: "Internal Server Error" })
    }
  })

  return res.status(200).json({
    deploymentIds,
    deleted: true,
  })
}

const handler = async (req: AuthedNextApiHandler, res: NextApiResponse) => {
  const { deployedByEmail } = req.query

  try {
    if (req.method === "GET" && deployedByEmail)
      return getDeploymentsByEmail(req, res, deployedByEmail.toString())
    if (req.method === "GET") return getDeployments(req, res)
    if (req.method === "POST") return createDeployment(req, res)
    if (req.method === "DELETE") return deleteDeployment(req, res)
  } catch (error) {
    return res.status(500).json({ message: "Internal Server Error" })
  }
}

export default withAuth(handler)
