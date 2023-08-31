import {
  deleteDocumentById,
  getDocsByField,
  saveDocument,
} from "@/utils/Api_SeverSideCon"
import { envOrFail } from "@/utils/env"
import { withAuth } from "@/utils/middleware"
import { AuthedNextApiHandler, IModule } from "@/utils/types"
import { NextApiResponse } from "next"

const gcpProjectId = envOrFail(
  "NEXT_PUBLIC_GCP_PROJECT_ID",
  process.env.NEXT_PUBLIC_GCP_PROJECT_ID,
)

const getModules = async (_req: AuthedNextApiHandler, res: NextApiResponse) => {
  const modules = await getDocsByField("modules", "projectId", gcpProjectId)

  if (modules) {
    return res.status(200).json({ modules })
  }

  return res.status(404)
}

const createModule = async (
  req: AuthedNextApiHandler,
  res: NextApiResponse,
) => {
  const { isAdmin } = req.user

  if (!isAdmin) {
    return res.status(403).json({ message: "Forbidden" })
  }

  const body = req.body
  //@ts-ignore
  const exModules: IModule[] = await getDocsByField(
    "modules",
    "projectId",
    gcpProjectId,
  )

  exModules.forEach(async (module: IModule) => {
    const checkModuleExist = body.modules.includes(module)
    if (!checkModuleExist) {
      await deleteDocumentById("modules", module.id)
    }
  })

  body.modules.forEach(async (module: IModule) => {
    module.projectId = gcpProjectId
    exModules.forEach(async (exModule: IModule) => {
      if (exModule.name === module.name) {
        await deleteDocumentById("modules", exModule.id)
      }
    })
    await saveDocument("modules", module)
  })

  //@ts-ignore
  const modules: IModule[] = await getDocsByField(
    "modules",
    "projectId",
    gcpProjectId,
  )

  return res.status(200).json({ modules })
}

const handler = async (req: AuthedNextApiHandler, res: NextApiResponse) => {
  try {
    if (req.method === "POST") return createModule(req, res)
    if (req.method === "GET") return getModules(req, res)
  } catch (error) {
    console.error(error)
    return res.status(500).json({ message: "Internal Server Error" })
  }
}

export default withAuth(handler)
