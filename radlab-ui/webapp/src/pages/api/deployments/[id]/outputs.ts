import { getDocsByField } from "@/utils/Api_SeverSideCon"
import { envOrFail } from "@/utils/env"
import { withAuth } from "@/utils/middleware"
import { AuthedNextApiHandler, IDeployment, TF_OUTPUT } from "@/utils/types"
import { Storage } from "@google-cloud/storage"
import { NextApiResponse } from "next"

const storage = new Storage()

const MODULE_DEPLOYMENT_BUCKET_NAME = envOrFail(
  "MODULE_DEPLOYMENT_BUCKET_NAME",
  process.env.MODULE_DEPLOYMENT_BUCKET_NAME,
)

const getOutputs = async (
  _req: AuthedNextApiHandler,
  res: NextApiResponse,
  id: string,
) => {
  const [deployment] = (await getDocsByField(
    "deployments",
    "deploymentId",
    id,
  )) as IDeployment[]

  if (!deployment) {
    return res.status(400).json({ message: "Not found" })
  }

  const fileName = `deployments/${deployment.module}_${deployment.deploymentId}/output/output.json`
  const [file] = await storage
    .bucket(MODULE_DEPLOYMENT_BUCKET_NAME)
    .file(fileName)
    .download()

  const allOutputs: TF_OUTPUT = JSON.parse(file.toString("utf-8"))

  // Remove entries where sensitive == true
  const outputs = Object.fromEntries(
    Object.entries(allOutputs).filter(([_, output]) => !output.sensitive),
  )

  return res.status(200).json({ outputs })
}

const handler = async (req: AuthedNextApiHandler, res: NextApiResponse) => {
  const { id } = req.query
  if (typeof id !== "string") throw new Error("Deployment ID must be a string")

  try {
    if (req.method === "GET") return getOutputs(req, res, id)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: "Internal Server Error" })
  }
}

export default withAuth(handler)
