import { NextApiRequest, NextApiResponse } from "next"

import { getSecretKeyValue, getGitHubModules } from "@/utils/api"
import { envOrFail } from "@/utils/env"
const GIT_TOKEN_SECRET_KEY_NAME = envOrFail(
  "GIT_TOKEN_SECRET_KEY_NAME",
  process.env.GIT_TOKEN_SECRET_KEY_NAME,
)
const getModulesFromGitHub = async (
  _: NextApiRequest,
  res: NextApiResponse,
) => {
  try {
    const secret = await getSecretKeyValue(GIT_TOKEN_SECRET_KEY_NAME)
    const modules = await getGitHubModules(secret)
    res.status(200).json(modules)
    return
  } catch (error: any) {
    res.status(500).send(error)
    console.error(error)
    return
  }
}

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  try {
    if (req.method === "GET") return getModulesFromGitHub(req, res)
  } catch (error) {
    res.status(500).json({
      message: "Internal Server Error",
    })
  }
}

export default handler
