import { NextApiRequest, NextApiResponse } from "next"

import axios from "axios"
import { generateAccessToken } from "@/utils/api"
import { envOrFail } from "@/utils/env"

const ADMIN_GROUP = envOrFail(
  "NEXT_PUBLIC_RAD_LAB_ADMIN_GROUP",
  process.env.NEXT_PUBLIC_RAD_LAB_ADMIN_GROUP,
  "rad-lab-admins",
)
const USER_GROUP = envOrFail(
  "NEXT_PUBLIC_RAD_LAB_USER_GROUP",
  process.env.NEXT_PUBLIC_RAD_LAB_USER_GROUP,
  "rad-lab-users",
)
const GCP_ORG = envOrFail(
  "NEXT_PUBLIC_GCP_ORGANIZATION",
  process.env.NEXT_PUBLIC_GCP_ORGANIZATION,
)

const handler = async (_req: NextApiRequest, res: NextApiResponse) => {
  const { email } = _req.query
  if (_req.method === "GET" && email) {
    if (!email) {
      return res.status(400).json({ message: "Please provide valid email" })
    }
    try {
      const token = await generateAccessToken()
      const data = await axios({
        method: "GET",
        url: `https://admin.googleapis.com/admin/directory/v1/groups/${ADMIN_GROUP}@${GCP_ORG}/hasMember/${email}`,
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })
      const isAdmin = data.data.isMember
      if (isAdmin) {
        return res.status(200).json({ isAdmin: true })
      } else {
        const token = await generateAccessToken()
        const data = await axios({
          method: "GET",
          url: `https://admin.googleapis.com/admin/directory/v1/groups/${USER_GROUP}@${GCP_ORG}/hasMember/${email}`,
          headers: {
            Authorization: `Bearer ${token}`,
          },
        })
        const isUser = data.data.isMember
        if (isUser) return res.status(200).json({ isAdmin: false })
      }
    } catch (error: any) {
      if (
        error.response.data.error.message ===
          "Missing required field: memberKey" ||
        "Invalid Input: memberKey"
      ) {
        return res.status(400).json({
          isValid: false,
        })
      }
      return res.status(500).json({
        result: error,
      })
    }
  }
}

export default handler
