import { NextApiRequest, NextApiResponse } from "next"
import { generateAccessToken } from "@/utils/api"
import { getDocsByField } from "@/utils/Api_SeverSideCon"
import axios from "axios"
import { envOrFail } from "@/utils/env"

const gcpProjectId = envOrFail(
  "NEXT_PUBLIC_GCP_PROJECT_ID",
  process.env.NEXT_PUBLIC_GCP_PROJECT_ID,
)

const getDeploymentVariables = async (
  _: NextApiRequest,
  res: NextApiResponse,
  id: string,
) => {
  try {
    const bucketName = `rad-lab-${gcpProjectId}`
    //@ts-ignore
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
    const fileName = `deployments/${deployment.module}_${deployment.deploymentId}/files/terraform.tfvars.json`
    const token = await generateAccessToken()
    const data = await axios({
      method: "GET",
      url: `https://storage.googleapis.com/${bucketName}/${fileName}`,
      headers: {
        Authorization: `Bearer ${token}`,
      },
    })
    const response = data.data
    res.status(200).json(response)
  } catch (error: any) {
    console.error(error)
    res.status(error?.response?.status || 500).json({
      message: error?.response?.statusText || "Internal server error",
    })
  }
}

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  const { id } = req.query
  if (typeof id !== "string") throw new Error("Deployment ID must be a string")

  try {
    if (req.method === "GET") return getDeploymentVariables(req, res, id)
  } catch (error) {
    res.status(500).json({
      message: "Internal Server Error",
    })
  }
}

export default handler
