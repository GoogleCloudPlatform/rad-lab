import axios from "axios"
import { envOrFail } from "@/utils/env"
import { firebaseAdmin, getApp } from "@/utils/firebaseAdmin"
import { CustomNextApiHandler, CustomNextApiRequest } from "@/utils/types"
import { NextApiRequest, NextApiResponse } from "next"

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

export const getGroupMembership = async (
  group: string,
  email: string,
  token: string,
) => {
  const url = `https://admin.googleapis.com/admin/directory/v1/groups/${group}@${GCP_ORG}/hasMember/${email}`
  const res = await axios.get(url, {
    headers: { Authorization: `Bearer ${token}` },
  })
  return !!res.data.isMember
}

export const inAdminGroup = (email: string, token: string) =>
  getGroupMembership(ADMIN_GROUP, email, token)

export const inUserGroup = (email: string, token: string) =>
  getGroupMembership(USER_GROUP, email, token)

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

export const withAuth = (handler: CustomNextApiHandler) => {
  return async (req: CustomNextApiRequest, res: NextApiResponse) => {
    try {
      const user = await verifyUser(req)

      if (!user || !user.email) {
        return res.status(401).json({
          message: "Unauthorized",
        })
      }

      const { email, token } = user

      const [isAdmin, isUser] = await Promise.all([
        inAdminGroup(email, token),
        inUserGroup(email, token),
      ])

      if (!isAdmin && !isUser) {
        return res.status(401).json({
          message: "Unauthorized",
        })
      }

      req.user = { ...user, isAdmin, isUser }
    } catch (_) {
      return res.status(401).json({
        message: "Unauthorized",
      })
    }

    return handler(req, res)
  }
}
