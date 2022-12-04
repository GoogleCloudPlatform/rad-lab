import { NextApiRequest, NextApiResponse } from "next"
import { TF_OUTPUT } from "@/utils/types"

import { getDocsByField } from "@/utils/Api_SeverSideCon"
import { envOrFail } from "@/utils/env"
import { Storage } from "@google-cloud/storage"
import { IDeployment } from "@/utils/types"

const storage = new Storage()

const MODULE_DEPLOYMENT_BUCKET_NAME = envOrFail(
  "MODULE_DEPLOYMENT_BUCKET_NAME",
  process.env.MODULE_DEPLOYMENT_BUCKET_NAME,
)

const getOutputs = async (
  _: NextApiRequest,
  res: NextApiResponse,
  id: string,
) => {
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

  try {
    const fileName = `deployments/${deployment.module}_${deployment.deploymentId}/output/output.json`
    const [file] = await storage
      .bucket(MODULE_DEPLOYMENT_BUCKET_NAME)
      .file(fileName)
      .download()

    const _outputs: TF_OUTPUT = JSON.parse(file.toString("utf-8"))

    // Remove entries where sensitive == true
    const outputs = Object.fromEntries(
      Object.entries(_outputs).filter(([_, output]) => !output.sensitive),
    )

    res.status(200).json({ outputs })
    return
  } catch (error) {
    res.status(500)
    return
  }
}

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  const { id } = req.query
  if (typeof id !== "string") throw new Error("Deployment ID must be a string")

  try {
    if (req.method === "GET") return getOutputs(req, res, id)
  } catch (error) {
    res.status(500).json({
      message: "Internal Server Error",
    })
  }
}

export default handler
