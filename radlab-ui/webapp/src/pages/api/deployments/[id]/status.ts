import { NextApiRequest, NextApiResponse } from "next"
import { getBuildStatus } from "@/utils/api"
import {
  getDocsByField,
  updateByField,
  updateBuildStatus,
} from "@/utils/Api_SeverSideCon"
import { IBuild, IDeployment, IBuildSteps } from "@/utils/types"

const getDeploymentStatus = async (
  _: NextApiRequest,
  res: NextApiResponse,
  id: string,
) => {
  // @ts-ignore
  const [deployment]: [IDeployment] = await getDocsByField(
    "deployments",
    "deploymentId",
    id,
  )

  if (!deployment) {
    res.status(400).send("Deployment not found")
    return
  }

  if (!deployment.builds || !deployment.builds.length) {
    res.status(404).send("Build ID not found")
    return
  }

  const mostRecentBuild = deployment.builds.sort(
    (a: IBuild, b: IBuild) => b.createdAt._seconds - a.createdAt._seconds,
  )[0]

  if (!mostRecentBuild) {
    res.status(404).send("Build ID not found")
    return
  }

  const cloudBuild = await getBuildStatus(
    mostRecentBuild.buildId,
    deployment.deploymentId,
  )

  if (!cloudBuild) {
    res.status(404)
    return
  }

  let tfState = ""
  cloudBuild.steps.forEach((step: IBuildSteps) => {
    if (step.id === "Apply") {
      tfState = step.status
      return
    }
  })
  const buildSteps = cloudBuild.steps.map((step: IBuildSteps) => {
    return { id: step.id, status: step.status }
  })
  const updateBuilds = {
    status: cloudBuild.status,
    buildId: mostRecentBuild.buildId,
  }
  await updateBuildStatus(id, updateBuilds)
  const updateData = {
    status: cloudBuild.status,
  }
  await updateByField("deployments", "deploymentId", id, updateData)
  res.status(200).json({
    buildStatus: cloudBuild.status,
    tfApplyState: tfState,
    buildSteps
  })
}

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  const { id } = req.query
  if (typeof id !== "string") throw new Error("Deployment ID must be a string")

  try {
    if (req.method === "GET") return getDeploymentStatus(req, res, id)
  } catch (error) {
    res.status(500).json({
      message: "Internal Server Error",
    })
  }
}

export default handler
