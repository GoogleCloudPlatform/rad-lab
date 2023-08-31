import {
  getDocsByField,
  updateBuildStatus,
  updateByField,
} from "@/utils/Api_SeverSideCon"
import { getBuildStatus } from "@/utils/api"
import { withAuth } from "@/utils/middleware"
import { AuthedNextApiHandler, IBuild, IDeployment } from "@/utils/types"
import { NextApiResponse } from "next"

const getDeploymentStatus = async (
  _req: AuthedNextApiHandler,
  res: NextApiResponse,
  id: string,
) => {
  // @ts-ignore
  const [deployment] = (await getDocsByField(
    "deployments",
    "deploymentId",
    id,
  )) as IDeployment[]

  if (!deployment || !deployment.builds?.length) {
    return res.status(400).json({ message: "Not found" })
  }

  const mostRecentBuild = deployment.builds.sort(
    (a: IBuild, b: IBuild) => b.createdAt._seconds - a.createdAt._seconds,
  )[0] as IBuild

  const cloudBuild = await getBuildStatus(
    mostRecentBuild.buildId,
    deployment.deploymentId,
  )

  if (!cloudBuild) {
    return res.status(400).json({ message: "Not found" })
  }

  let tfState = ""
  cloudBuild.steps.forEach((step: Record<string, any>) => {
    if (step.id === "Apply") {
      tfState = step.status
      return
    }
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
  })
}

const handler = async (req: AuthedNextApiHandler, res: NextApiResponse) => {
  const { id } = req.query
  if (typeof id !== "string") throw new Error("Deployment ID must be a string")

  try {
    if (req.method === "GET") return getDeploymentStatus(req, res, id)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: "Internal Server Error" })
  }
}

export default withAuth(handler)
