import { getGitHubModulesData, getSecretKeyValue } from "@/utils/api"
import { envOrFail } from "@/utils/env"
import { withAuth } from "@/utils/middleware"
import { AuthedNextApiHandler } from "@/utils/types"
import { NextApiResponse } from "next"

const getModuleDataFromGitHub = async (
  req: AuthedNextApiHandler,
  res: NextApiResponse,
) => {
  const GIT_TOKEN_SECRET_KEY_NAME = envOrFail(
    "GIT_TOKEN_SECRET_KEY_NAME",
    process.env.GIT_TOKEN_SECRET_KEY_NAME,
  )

  const { path } = req.body
  const secret = await getSecretKeyValue(GIT_TOKEN_SECRET_KEY_NAME)
  try {
    const modules = await getGitHubModulesData(path, secret)
    return res.status(200).json(modules)
  } catch (error: any) {
    return res.status(error.response.status).json({ message: error.message })
  }
}

const handler = async (req: AuthedNextApiHandler, res: NextApiResponse) => {
  try {
    if (req.method === "POST") return getModuleDataFromGitHub(req, res)
  } catch (error) {
    return res.status(500).json({ message: "Internal Server Error" })
  }
}

export default withAuth(handler)
