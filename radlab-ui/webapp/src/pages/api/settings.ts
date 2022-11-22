import { NextApiRequest, NextApiResponse } from "next"

import { pushPubSubMsg } from "@/utils/api"
import { DEPLOYMENT_ACTIONS } from "@/utils/types"
import { envOrFail } from "@/utils/env"

import {
  getDocsByField,
  saveDocument,
  deleteDocByFieldValue,
} from "@/utils/Api_SeverSideCon"

const gcpProjectId = envOrFail(
  "NEXT_PUBLIC_GCP_PROJECT_ID",
  process.env.NEXT_PUBLIC_GCP_PROJECT_ID,
)
const serviceAccountEmail = envOrFail(
  "NEXT_PUBLIC_GCP_SERVICE_ACCOUNT_EMAIL",
  process.env.NEXT_PUBLIC_GCP_SERVICE_ACCOUNT_EMAIL,
)

const getSettings = async (_: NextApiRequest, res: NextApiResponse) => {
  const settings = await getDocsByField("settings", "projectId", gcpProjectId)
  res.status(200).json({ settings: settings[0] ?? null })
}

const createSettings = async (req: NextApiRequest, res: NextApiResponse) => {
  const email = req.body.email
  delete req.body.email
  const body = {
    projectId: gcpProjectId,
    createdBy: email,
    variables: {
      ...req.body,
    },
  }
  await deleteDocByFieldValue("settings", "projectId", gcpProjectId)
  const data = await saveDocument("settings", body)

  const pubSubData = {
    projectId: gcpProjectId,
    bucketName: `rad-lab-${gcpProjectId}`,
    feature: DEPLOYMENT_ACTIONS.SETTINGS,
    serviceAccount: serviceAccountEmail,
  }

  try {
    await pushPubSubMsg(pubSubData)
  } catch (error) {
    console.error(error)
  }

  res.status(200).json({
    data,
  })
}

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  try {
    if (req.method === "GET") return getSettings(req, res)
    if (req.method === "POST") return createSettings(req, res)
  } catch (error) {
    console.error("Settings error", error)
    res.status(500).json({
      message: "Internal Server Error",
    })
  }
}

export default handler
