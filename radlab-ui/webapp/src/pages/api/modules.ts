import { NextApiRequest, NextApiResponse } from "next"
import { IModule } from "@/utils/types"
import { envOrFail } from "@/utils/env"
import {
  getDocsByField,
  deleteDocumentById,
  saveDocument,
} from "@/utils/Api_SeverSideCon"

const gcpProjectId = envOrFail(
  "NEXT_PUBLIC_GCP_PROJECT_ID",
  process.env.NEXT_PUBLIC_GCP_PROJECT_ID,
)

const getModules = async (_: NextApiRequest, res: NextApiResponse) => {
  const modules = await getDocsByField("modules", "projectId", gcpProjectId)

  if (modules) {
    res.status(200).json({ modules })
  } else {
    res.status(404)
  }
}

const createModule = async (req: NextApiRequest, res: NextApiResponse) => {
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

  res.status(200).json({ modules })
}

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  try {
    if (req.method === "POST") return createModule(req, res)
    if (req.method === "GET") return getModules(req, res)
  } catch (error) {
    console.error("Modules error", error)
    res.status(500).json({
      message: "Internal Server Error",
    })
  }
}

export default handler
