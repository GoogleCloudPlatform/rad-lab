import { NextApiRequest, NextApiResponse } from "next"
import { getDocsByField } from "@/utils/Api_SeverSideCon"
import { envOrFail } from "@/utils/env"
import { GetSignedUrlConfig, Storage } from "@google-cloud/storage"
import { IBuild, IDeployment } from "@/utils/types"

const storage = new Storage()

const MODULE_DEPLOYMENT_BUCKET_NAME = envOrFail(
  "MODULE_DEPLOYMENT_BUCKET_NAME",
  process.env.MODULE_DEPLOYMENT_BUCKET_NAME,
)

const getDeploymentLogs = async (
  _: NextApiRequest,
  res: NextApiResponse,
  id: string,
) => {
  // These options will allow temporary read access to the file
  const options: GetSignedUrlConfig = {
    version: "v4",
    action: "read",
    expires: Date.now() + 180 * 60 * 1000, // 3 hr
  }
  // @ts-ignore
  const [deployment]: [IDeployment] = await getDocsByField(
    "deployments",
    "deploymentId",
    id,
  )

  if (!deployment) {
    res.status(400).json({
      message: "Deployment not found",
    })
    return
  }

  if (!deployment.builds || !deployment.builds.length) {
    res.status(404).json({
      message: "Build ID not found",
    })
    return
  }

  const mostRecentBuild = deployment.builds.sort(
    (a: IBuild, b: IBuild) => b.createdAt._seconds - a.createdAt._seconds,
  )[0]

  if (!mostRecentBuild) {
    res.status(404).send("Build ID not found")
    return
  }

  // Get a v4 signed URL for reading the file
  const bucketName = MODULE_DEPLOYMENT_BUCKET_NAME
  const fileName = `deployments/${deployment.module}_${deployment.deploymentId}/logs/log-${mostRecentBuild.buildId}.txt`
  const [url] = await storage
    .bucket(bucketName)
    .file(fileName)
    .getSignedUrl(options)

  res.status(200).json({ url })
}

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  const { id } = req.query
  if (typeof id !== "string") throw new Error("Deployment ID must be a string")

  try {
    if (req.method === "GET") return getDeploymentLogs(req, res, id)
  } catch (error) {
    res.status(500).json({
      message: "Internal Server Error",
    })
  }
}

export default handler
