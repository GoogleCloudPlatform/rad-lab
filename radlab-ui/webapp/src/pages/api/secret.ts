import { NextApiRequest, NextApiResponse } from "next"
import { envOrFail } from "@/utils/env"
import { SecretManagerServiceClient } from "@google-cloud/secret-manager"
import { ISecretManagerReq } from "@/utils/types"

const secretmanagerClient = new SecretManagerServiceClient()

const gcpProjectId = envOrFail(
  "NEXT_PUBLIC_GCP_PROJECT_ID",
  process.env.NEXT_PUBLIC_GCP_PROJECT_ID,
)

const secretManagerLocation = envOrFail(
  "SECRET_MANAGER_LOCATION",
  process.env.SECRET_MANAGER_LOCATION,
  "us-central1",
)

export const getSecretKeyValue = async (secretId: string) => {
  try {
    const parent = `projects/${gcpProjectId}`
    const request = {
      name: `${parent}/secrets/${secretId}/versions/latest`,
    }
    const [response] = await secretmanagerClient.accessSecretVersion(request)
    const value = response.payload?.data?.toString()
    return value
  } catch (error) {
    console.error(error)
    return null
  }
}

const createSecret = async (req: NextApiRequest, res: NextApiResponse) => {
  const { key: secretId, value }: ISecretManagerReq = req.body

  const parent = `projects/${gcpProjectId}`
  const secretKeyName = `${parent}/secrets/${secretId}`

  const request = {
    parent,
    secretId,
    secret: {
      replication: {
        userManaged: {
          replicas: [
            {
              location: secretManagerLocation,
            },
          ],
        },
      },
    },
  }

  let runFinally: boolean = true
  try {
    await secretmanagerClient.createSecret(request)
  } catch (error: any) {
    // exit finally if exception occures other than secret already exists
    if (error.code !== 6) {
      runFinally = false
      throw new Error("Create secret failed")
    }
  } finally {
    if (runFinally) {
      const buff = Buffer.from(value)
      const base64Data = buff.toString("base64")

      const versionRequest = {
        parent: secretKeyName,
        payload: {
          data: base64Data,
        },
      }

      await secretmanagerClient.addSecretVersion(versionRequest)
    }
  }

  res.status(200).end()
}

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  try {
    if (req.method === "POST") return await createSecret(req, res)
  } catch (error) {
    console.error(error)
    return res.status(500).end()
  }
}
export default handler
