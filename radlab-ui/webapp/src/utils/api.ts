import { envOrFail } from "@/utils/env"
import { IAMCredentialsClient } from "@google-cloud/iam-credentials"
import { getDocsByField } from "@/utils/Api_SeverSideCon"
import { mergeAll } from "ramda"
import { PubSub } from "@google-cloud/pubsub"
import axios from "axios"

import { IDeployment, IModule } from "@/utils/types"

const { SecretManagerServiceClient } = require("@google-cloud/secret-manager")
const client = new SecretManagerServiceClient()

const GCP_PROJECT_ID = envOrFail(
  "NEXT_PUBLIC_GCP_PROJECT_ID",
  process.env.NEXT_PUBLIC_GCP_PROJECT_ID,
)
const PUBSUB_DELETE_TOPIC = envOrFail(
  "NEXT_PUBLIC_PUBSUB_DEPLOYMENTS_DELETE_TOPIC",
  process.env.NEXT_PUBLIC_PUBSUB_DEPLOYMENTS_DELETE_TOPIC,
)
const PUBSUB_CREATE_TOPIC = envOrFail(
  "NEXT_PUBLIC_PUBSUB_DEPLOYMENTS_TOPIC",
  process.env.NEXT_PUBLIC_PUBSUB_DEPLOYMENTS_TOPIC,
)
const GCP_SERVICE_ACCOUNT_EMAIL = envOrFail(
  "NEXT_PUBLIC_GCP_SERVICE_ACCOUNT_EMAIL",
  process.env.NEXT_PUBLIC_GCP_SERVICE_ACCOUNT_EMAIL,
)

const NEXT_PUBLIC_GIT_API_URL = envOrFail(
  "NEXT_PUBLIC_GIT_API_URL",
  process.env.NEXT_PUBLIC_GIT_API_URL,
)

const NEXT_PUBLIC_GIT_BRANCH = envOrFail(
  "NEXT_PUBLIC_GIT_BRANCH",
  process.env.NEXT_PUBLIC_GIT_BRANCH,
)

export const generateAccessToken = async function () {
  try {
    // Creates a client
    const client = new IAMCredentialsClient()
    const scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/cloud-platform.read-only",
      "https://www.googleapis.com/auth/admin.directory.group.member.readonly",
    ]
    //Generates token
    const [token] = await client.generateAccessToken({
      name: `projects/-/serviceAccounts/${GCP_SERVICE_ACCOUNT_EMAIL}`,
      scope: scopes,
    })
    return token.accessToken
  } catch (error) {
    console.error("Error", error)
    return
  }
}

export const pushPubSubMsg = async function (data: Record<string, any>) {
  try {
    const topicName =
      data.action === "DELETE"
        ? `${PUBSUB_DELETE_TOPIC}`
        : `${PUBSUB_CREATE_TOPIC}`
    // Instantiates a client
    const pubsub = new PubSub({ projectId: GCP_PROJECT_ID })
    pubsub
      .topic(topicName)
      .publishMessage({ json: data })
      .then((response) => {
        console.log("messaged pushed>>>>", response)
      })
      .catch((error) => {
        console.log("Pubsub error>>>", error)
      })
  } catch (error) {
    console.error("Exception:", error)
    throw error
  }
}

export const getBuildStatus = async (buildId: string, deploymentId: string) => {
  try {
    const token = await generateAccessToken()
    let data = await axios({
      method: "GET",
      url: `https://cloudbuild.googleapis.com/v1/projects/${GCP_PROJECT_ID}/builds/${buildId}`,
      headers: {
        Authorization: `Bearer ${token}`,
      },
    })
    data.data.deploymentId = deploymentId
    return data.data || null
  } catch (error) {
    console.error(error)
    return null
  }
}

export const mergeVariables = async (body: IDeployment) => {
  const [settings]: Record<string, any>[] = await getDocsByField(
    "settings",
    "projectId",
    GCP_PROJECT_ID,
  )
  const adminVars = settings?.variables
  // @ts-ignore
  const modules: IModule[] = await getDocsByField(
    "modules",
    "projectId",
    GCP_PROJECT_ID,
  )
  let moduleVars = {}
  modules.forEach((module: IModule) => {
    if (module.name === body.module) {
      moduleVars = module.variables
    }
  })
  const userVars = { ...body.variables }
  const billingId = adminVars?.billing_account_id
  const variables = mergeAll([userVars, moduleVars, adminVars])
  delete variables.email
  delete variables.id
  return { billingId, variables }
}

export const getBuildList = async () => {
  try {
    const token = await generateAccessToken()
    const data = await axios({
      method: "GET",
      url: `https://cloudbuild.googleapis.com/v1/projects/${GCP_PROJECT_ID}/builds?pageSize=1000`,
      headers: {
        Authorization: `Bearer ${token}`,
      },
    })
    return data.data.builds || null
  } catch (error) {
    console.error(error)
    return null
  }
}

export const getSecretKeyValue = async (secretKey: string): Promise<string> => {
  try {
    const name = `projects/${GCP_PROJECT_ID}/secrets/${secretKey}/versions/latest`
    const [version] = await client.accessSecretVersion({
      name,
    })
    const payload = version.payload.data.toString() as string

    if (!payload) {
      throw new Error("No secret found for: " + secretKey)
    }

    return payload.trim()
  } catch (error: any) {
    console.error(error)
    throw error
  }
}

export const getGitHubModules = async (token: string) => {
  try {
    const result = await axios({
      method: "GET",
      url: `${NEXT_PUBLIC_GIT_API_URL}/contents/modules?ref=${NEXT_PUBLIC_GIT_BRANCH}`,
      headers: {
        Authorization: `Bearer ${token}`,
      },
    })
    return result.data || null
  } catch (error) {
    console.error(error)
    throw error
  }
}

export const getGitHubVariables = async (moduleName: string, token: string) => {
  try {
    const result = await axios({
      method: "GET",
      url: `${NEXT_PUBLIC_GIT_API_URL}/contents/modules/${moduleName}/variables.tf?ref=${NEXT_PUBLIC_GIT_BRANCH}`,
      headers: {
        Authorization: `Bearer ${token}`,
      },
    })
    return result.data || null
  } catch (error) {
    console.error(error)
    throw error
  }
}
