import { NextApiRequest, NextApiResponse } from "next"

import axios from "axios"
import { generateAccessToken } from "@/utils/api"
import { envOrFail } from "@/utils/env"
import { IRegion } from "@/utils/types"

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
    const itemsPage = response.data.items
    const regions: IRegion[] = itemsPage.map((element: any) => {
      return {
        id: element.id,
        name: element.name,
        zones: (element.zones || []).map((zone: string) =>
          zone.split("/").pop(),
        ),
      }
    })

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
  } catch (error: any) {
    console.log(error)
    return res.status(500).json({
      result: error,
    })
  }
}

export default handler
