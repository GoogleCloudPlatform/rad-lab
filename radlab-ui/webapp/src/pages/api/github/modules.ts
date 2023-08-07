import { getGitHubModules, getSecretKeyValue } from "@/utils/api"
import { envOrFail } from "@/utils/env"
import { withAuth } from "@/utils/middleware"
import { AuthedNextApiHandler } from "@/utils/types"
import { NextApiResponse } from "next"

const GIT_TOKEN_SECRET_KEY_NAME = envOrFail(
  "GIT_TOKEN_SECRET_KEY_NAME",
  process.env.GIT_TOKEN_SECRET_KEY_NAME,
)
const getModulesFromGitHub = async (
  _req: AuthedNextApiHandler,
  res: NextApiResponse,
) => {
  try {
    const secret = await getSecretKeyValue(GIT_TOKEN_SECRET_KEY_NAME)
    const modules = await getGitHubModules(secret)
    return res.status(200).json(modules)
  } catch (error) {
    return res.status(500).send(error)
  }
}

const handler = async (req: AuthedNextApiHandler, res: NextApiResponse) => {
  try {
    if (req.method === "GET") return getModulesFromGitHub(req, res)
  } catch (error) {
    return res.status(500).json({ message: "Internal Server Error" })
  }
}

export default withAuth(handler)
