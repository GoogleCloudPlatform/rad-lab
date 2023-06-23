import { getDocsByField } from "@/utils/Api_SeverSideCon"
import { generateAccessToken } from "@/utils/api"
import { envOrFail } from "@/utils/env"
import { withAuth } from "@/utils/middleware"
import { AuthedNextApiHandler, IDeployment } from "@/utils/types"
import axios from "axios"
import { NextApiResponse } from "next"

const gcpProjectId = envOrFail(
  "NEXT_PUBLIC_GCP_PROJECT_ID",
  process.env.NEXT_PUBLIC_GCP_PROJECT_ID,
)

const getDeploymentVariables = async (
  _req: AuthedNextApiHandler,
  res: NextApiResponse,
  id: string,
) => {
  try {
    const bucketName = `rad-lab-${gcpProjectId}`

    const [deployment] = (await getDocsByField(
      "deployments",
      "deploymentId",
      id,
    )) as IDeployment[] | undefined[]

    if (!deployment) {
      res.status(400).json({
        message: "Not found",
      })
      return
    }
    const fileName = `deployments/${deployment.module}_${deployment.deploymentId}/files/terraform.tfvars.json`
    const token = await generateAccessToken()

    if (!token) {
      throw new Error("Failed to generate access token")
    }

    const response = await axios({
      method: "GET",
      url: `https://storage.googleapis.com/${bucketName}/${fileName}`,
      headers: {
        Authorization: `Bearer ${token}`,
      },
    })

    res.status(200).json(response.data)
  } catch (error: any) {
    console.error(error)
    res.status(error?.response?.status || 500).json({
      message: error?.response?.statusText || "Internal server error",
    })
  }
}

const handler = async (req: AuthedNextApiHandler, res: NextApiResponse) => {
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

export default withAuth(handler)
