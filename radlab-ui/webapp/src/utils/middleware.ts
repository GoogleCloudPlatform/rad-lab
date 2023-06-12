import { firebaseAdmin, getApp } from "@/utils/firebaseAdmin"
import { NextApiRequest, NextApiResponse } from "next"
import { generateAccessToken } from "@/utils/api"
import axios from "axios"
import { envOrFail } from "@/utils/env"
import { CustomNextApiHandler, CustomNextApiRequest } from "@/utils/types"

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

export function withAuth(handler: CustomNextApiHandler) {
  return async (req: CustomNextApiRequest, res: NextApiResponse) => {
    try {
      const user = await verifyUser(req)

      if (!user || !user.email) {
        return res.status(401).json({
          message: "Unauthorized",
        })
      }

      const email = user.email
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
        user.isAdmin = isAdmin
      } else {
        const data = await axios({
          method: "GET",
          url: `https://admin.googleapis.com/admin/directory/v1/groups/${USER_GROUP}@${GCP_ORG}/hasMember/${email}`,
          headers: {
            Authorization: `Bearer ${token}`,
          },
        })
        const isUser = data.data.isMember
        user.isUser = isUser
      }

      if (!user.isAdmin && !user.isUser) {
        return res.status(401).json({
          message: "Unauthorized",
        })
      }
      //@ts-ignore
      req.user = user
    } catch (_) {
      return res.status(401).json({
        message: "Unauthorized",
      })
    }

    return handler(req, res)
  }
}

export const verifyUser = async (req: NextApiRequest) => {
  let token = req.cookies.token
  if (!token && req.headers.authorization) {
    token = req.headers.authorization.split(/\s+/)[1]
  }

  if (!token) {
    throw new Error("No token found")
  }

  return await decodeToken(token)
}

export const decodeToken = async (token: string) => {
  try {
    return await firebaseAdmin.auth(getApp()).verifyIdToken(token)
  } catch (error) {
    console.error(error)
    return null
  }
}
