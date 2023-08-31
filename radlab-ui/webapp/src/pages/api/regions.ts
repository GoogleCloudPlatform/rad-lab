import { NextApiRequest, NextApiResponse } from "next"

import axios from "axios"
import { generateAccessToken } from "@/utils/api"
import { envOrFail } from "@/utils/env"
import { IGoogleCloudRegion, IRegion } from "@/utils/types"

const projectId = envOrFail(
  "NEXT_PUBLIC_GCP_PROJECT_ID",
  process.env.NEXT_PUBLIC_GCP_PROJECT_ID,
)

const getRegions = async (_req: NextApiRequest, res: NextApiResponse) => {
  const token = await generateAccessToken()

  const response = await axios({
    method: "GET",
    url: `https://compute.googleapis.com/compute/v1/projects/${projectId}/regions`,
    headers: {
      Authorization: `Bearer ${token}`,
    },
  })

  const googleCloudRegions = response.data.items as IGoogleCloudRegion[]

  const regions: IRegion[] = googleCloudRegions.map((cloudRegion) => ({
    id: cloudRegion.id,
    name: cloudRegion.name,
    zones: (cloudRegion.zones || []).map(
      (zone) => zone.split("/").pop() as string,
    ),
  }))

  return res.status(200).json({ regions })
}

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  try {
    if (req.method === "GET") return await getRegions(req, res)
  } catch (error: any) {
    console.error(error)
    return res.status(500).json({ message: "Internal Server Error" })
  }
}

export default handler
