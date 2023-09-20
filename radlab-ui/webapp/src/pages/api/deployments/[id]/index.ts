import {
  canAccessDeployment,
  getDocsByField,
  updateByField,
} from "@/utils/Api_SeverSideCon"
import { mergeVariables, pushPubSubMsg } from "@/utils/api"
import { envOrFail } from "@/utils/env"
import { configureEmailAndSend } from "@/utils/mailHandler"
import { withAuth } from "@/utils/middleware"
import {
  AuthedNextApiHandler,
  DEPLOYMENT_ACTIONS,
  IDeployment,
  IPubSubMsg,
} from "@/utils/types"
import { Timestamp } from "firebase-admin/firestore"
import { NextApiResponse } from "next"

const gcpProjectId = envOrFail(
  "NEXT_PUBLIC_GCP_PROJECT_ID",
  process.env.NEXT_PUBLIC_GCP_PROJECT_ID,
)

const getDeployment = async (
  req: AuthedNextApiHandler,
  res: NextApiResponse,
  id: string,
) => {
  const { isAdmin, email } = req.user

  if (!email) {
    return res.status(401).json({ message: "Unauthorized" })
  }

  const deployments: IDeployment[] = await getDocsByField(
    "deployments",
    "deploymentId",
    id,
  )
  const deployment = deployments[0]

  if (!deployment) {
    return res.status(400).json({ message: "Not found" })
  }

  if (!canAccessDeployment(deployment, email, isAdmin)) {
    return res.status(403).json({ message: "Forbidden" })
  }

  res.status(200).json({ deployment })
}

const deleteDeployment = async (
  req: AuthedNextApiHandler,
  res: NextApiResponse,
  id: string,
) => {
  const { isAdmin, email } = req.user

  if (!email) {
    return res.status(401).json({ message: "Unauthorized" })
  }

  let [deployment]: [IDeployment] = await getDocsByField(
    "deployments",
    "deploymentId",
    id,
  )

  if (!deployment) {
    return res.status(400).json({ message: "Not found" })
  }

  if (!canAccessDeployment(deployment, email, isAdmin)) {
    return res.status(403).json({ message: "Forbidden" })
  }

  const body = req.body
  const pubSubData: IPubSubMsg = {
    module: deployment.module,
    deploymentId: id,
    projectId: gcpProjectId,
    action: DEPLOYMENT_ACTIONS.DELETE,
    user: body.deployedByEmail,
    variables: {
      module_name: deployment.module,
      deployment_id: id,
    },
  }
  delete pubSubData.variables.resource_creator_identity

  await pushPubSubMsg(pubSubData)

  deployment = {
    ...deployment,
    // @ts-ignore
    deletedAt: Timestamp.now(),
  }

  await updateByField("deployments", "deploymentId", id, deployment)

  await configureEmailAndSend(
    "RAD Lab Module has been deleted for you!",
    deployment,
  )

  res.status(200).json({ id, deleted: true })
}

const updateDeployment = async (
  req: AuthedNextApiHandler,
  res: NextApiResponse,
  id: string,
) => {
  const { isAdmin, email } = req.user

  if (!email) {
    return res.status(401).json({ message: "Unauthorized" })
  }

  const [deployment]: IDeployment[] = await getDocsByField(
    "deployments",
    "deploymentId",
    id,
  )

  if (!deployment) {
    return res.status(400).json({ message: "Not found" })
  }

  if (!canAccessDeployment(deployment, email, isAdmin)) {
    return res.status(401).json({ message: "Unauthorized" })
  }

  const body = req.body
  if (!deployment) {
    return res.status(400).json({ message: "Not found" })
  }

  const { billingId, variables } = await mergeVariables(body)

  body.variables = variables
  const pubSubData: IPubSubMsg = {
    module: deployment.module,
    deploymentId: deployment.deploymentId,
    projectId: gcpProjectId,
    action: DEPLOYMENT_ACTIONS.UPDATE,
    user: body.deployedByEmail,
    variables: {
      ...variables,
      billing_account_id: billingId,
      deployment_id: deployment.deploymentId,
    },
  }

  delete pubSubData.variables.resource_creator_identity

  try {
    await pushPubSubMsg(pubSubData)
  } catch (error) {
    console.error(error)
  }
  await updateByField("deployments", "deploymentId", id, body)
  const deployments = await getDocsByField("deployments", "deploymentId", id)

  const [upDatedDeployment] = deployments
  await configureEmailAndSend(
    "RAD Lab Module has been updated for you!",
    upDatedDeployment,
  )

  res.status(200).json({ deployments })
}

const handler = async (req: AuthedNextApiHandler, res: NextApiResponse) => {
  const { id } = req.query
  if (typeof id !== "string") throw new Error("Deployment ID must be a string")

  try {
    if (req.method === "GET") return getDeployment(req, res, id)
    if (req.method === "PUT") return updateDeployment(req, res, id)
    if (req.method === "DELETE") return deleteDeployment(req, res, id)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: "Internal Server Error" })
  }
}

export default withAuth(handler)
