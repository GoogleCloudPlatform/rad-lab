import {
  getDocsByField,
  isCreatorOfDeployment,
  updateByField,
} from "@/utils/Api_SeverSideCon"
import { mergeVariables, pushPubSubMsg } from "@/utils/api"
import { envOrFail } from "@/utils/env"
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
  const deployments: IDeployment[] = await getDocsByField(
    "deployments",
    "deploymentId",
    id,
  )
  const deployment = deployments[0]

  if (!deployment) {
    res.status(400).json({
      deployment: null,
      message: "Not found",
    })
    return
  }

  // Users can only access their own deployments
  if (!req.user.isAdmin && deployment.deployedByEmail !== req.user.email) {
    res.status(403).json({
      deployment: null,
      message: "Forbidden",
    })
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
    return res.status(401).json({
      message: "Unauthorized",
    })
  }

  let [deployment]: [IDeployment] = await getDocsByField(
    "deployments",
    "deploymentId",
    id,
  )

  if (!deployment) {
    res.status(400).json({
      message: "Not found",
    })
    return
  }

  if (!isAdmin && !isCreatorOfDeployment(deployment, email)) {
    return res.status(403).json({
      message: "Forbidden",
    })
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

  try {
    await pushPubSubMsg(pubSubData)
  } catch (error) {
    console.error(error)
    res.status(500)
    return
  }

  deployment = {
    ...deployment,
    // @ts-ignore
    deletedAt: Timestamp.now(),
  }

  await updateByField("deployments", "deploymentId", id, deployment)

  res.status(200).json({
    id,
    deleted: true,
  })
}

const updateDeployment = async (
  req: AuthedNextApiHandler,
  res: NextApiResponse,
  id: string,
) => {
  const { isAdmin, email } = req.user

  if (!email) {
    return res.status(401).json({
      message: "Unauthorized",
    })
  }

  const [deployment]: IDeployment[] = await getDocsByField(
    "deployments",
    "deploymentId",
    id,
  )

  if (!deployment) {
    res.status(400).json({
      message: "Not found",
    })
    return
  }

  if (!isAdmin && !isCreatorOfDeployment(deployment, email)) {
    return res.status(401).json({
      message: "Unauthorized",
    })
  }

  const body = req.body
  if (!deployment) {
    res.status(400).send("Deployment not found")
    return
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
    res.status(500).json({
      message: "Internal Server Error",
    })
  }
}

export default withAuth(handler)
