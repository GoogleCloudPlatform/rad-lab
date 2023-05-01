import { generateAccessToken } from "@/utils/api"
import { zoneFromGCPResource } from "@/utils/data"
import { envOrFail } from "@/utils/env"
import { GCPRegion, IRegion } from "@/utils/types"
import axios from "axios"
import { NextApiRequest, NextApiResponse } from "next"

const projectId = envOrFail(
  "NEXT_PUBLIC_GCP_PROJECT_ID",
  process.env.NEXT_PUBLIC_GCP_PROJECT_ID,
)

const getRegions = async (_: NextApiRequest, res: NextApiResponse) => {
  const token = await generateAccessToken()
  try {
    const response = await axios({
      method: "GET",
      url: `https://compute.googleapis.com/compute/v1/projects/${projectId}/regions`,
      headers: {
        Authorization: `Bearer ${token}`,
      },
    })
    const itemsPage = response.data.items as GCPRegion[]
    const regions: IRegion[] = itemsPage.map((gcpRegion) => ({
      id: gcpRegion.id,
      name: gcpRegion.name,
      zones: gcpRegion.zones.map(zoneFromGCPResource),
    }))

    return res.status(200).json({ regions })
  } catch (error) {
    return res.status(500).json({
      result: error,
    })
  }
}

const handler = async (_req: NextApiRequest, res: NextApiResponse) => {
  try {
    if (_req.method === "GET") return await getRegions(_req, res)
  } catch (error) {
    console.log(error)
    return res.status(500).json({
      result: error,
    })
  }
}

export default handler
