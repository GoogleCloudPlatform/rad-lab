import { NextApiRequest, NextApiResponse } from "next"
import { v4 as uuidv4 } from "uuid"
import { mergeVariables, pushPubSubMsg, getBuildStatus } from "@/utils/api"
import {
  DEPLOYMENT_ACTIONS,
  IDeployment,
  IPubSubMsg,
  IBuild,
  DEPLOYMENT_STATUS,
} from "@/utils/types"
import { envOrFail } from "@/utils/env"
import { Timestamp } from "firebase-admin/firestore"
const gcpProjectId = envOrFail(
  "NEXT_PUBLIC_GCP_PROJECT_ID",
  process.env.NEXT_PUBLIC_GCP_PROJECT_ID,
)

import {
  getAllDocuments,
  getDocsByField,
  saveDocument,
  updateByField,
} from "@/utils/Api_SeverSideCon"

const createDeployment = async (req: NextApiRequest, res: NextApiResponse) => {
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
    res.status(500).json({
      message: "Failed to return document",
    })
    return
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

  res.status(200).json({
    response,
  })
}

const getDeployments = async (_: NextApiRequest, res: NextApiResponse) => {
  const deployments = await getAllDocuments("deployments")
  const possiblyStaleDeployments = deployments.filter(
    (deployment: IDeployment) => {
      return (
        deployment.status &&
        deployment.builds?.length &&
        [
          DEPLOYMENT_STATUS.QUEUED,
          DEPLOYMENT_STATUS.WORKING,
          DEPLOYMENT_STATUS.PENDING,
        ].includes(deployment.status)
      )
    },
  )
  if (!possiblyStaleDeployments.length) {
    res.status(200).json({ deployments })
    return
  }

  let getBuilds: Promise<any>[] = []
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
  const deploymentsList = await getAllDocuments("deployments")
  res.status(200).json({ deployments: deploymentsList })
}

const getDeploymentsByEmail = async (
  _: NextApiRequest,
  res: NextApiResponse,
  deployedByEmail: string,
) => {
  const deployments = await getDocsByField(
    "deployments",
    "deployedByEmail",
    deployedByEmail,
  )
  res.status(200).json({ deployments })
}

const deleteDeployment = async (req: NextApiRequest, res: NextApiResponse) => {
  const body = req.body
  const deploymentIds = body.deploymentIds
  if (!deploymentIds || !deploymentIds.length) {
    res.status(404).send("Missing deploymentIds from body")
    return
  }
  for (let i = 0; i < deploymentIds.length; i++) {
    const deploymentId = deploymentIds[i]
    // @ts-ignore
    let [deployment]: IDeployment = await getDocsByField(
      "deployments",
      "deploymentId",
      deploymentId,
    )
    if (!deployment) {
      res.status(400).json({
        message: `Deployment Not found for id ${deploymentId}`,
      })
      return
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
      deployment.deletedAt = Timestamp.now()
      await updateByField(
        "deployments",
        "deploymentId",
        deploymentId,
        deployment,
      )
    } catch (error) {
      console.error(error)
      res.status(500).send("Internal server error")
      return
    }
  }
  res.status(200).json({
    deploymentIds,
    deleted: true,
  })
}

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  const { deployedByEmail } = req.query

  try {
    if (req.method === "GET" && deployedByEmail)
      return getDeploymentsByEmail(req, res, deployedByEmail.toString())
    if (req.method === "GET") return getDeployments(req, res)
    if (req.method === "POST") return createDeployment(req, res)
    if (req.method === "DELETE") return deleteDeployment(req, res)
  } catch (error) {
    console.error("Deployments error", error)
    res.status(500).json({
      message: "Internal Server Error",
    })
  }
}

export default handler
