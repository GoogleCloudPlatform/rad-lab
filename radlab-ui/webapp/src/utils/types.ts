import { DecodedIdToken } from "firebase-admin/lib/auth/token-verifier"
import { NextApiRequest, NextApiResponse } from "next"
import React from "react"
import { z } from "zod"

export type IAuthProvider = "google" | "password"

export type INavigationItem = {
  name: string
  href: string
}

export enum SORT_FIELD {
  MODULE = "module",
  DEPLOYMENTID = "deploymentId",
  PROJECTID = "projectId",
  STATUS = "status",
  EMAIL = "deployedByEmail",
  CREATEDAT = "createdAt",
}

export enum SORT_DIRECTION {
  ASC,
  DESC,
}

export enum SORT_BUILD_FIELD {
  EMAIL = "user",
  CREATEDAT = "createdAt",
  ACTION = "action",
  BUILDID = "buildId",
}

export enum DEPLOYMENT_ACTIONS {
  CREATE = "CREATE",
  DELETE = "DELETE",
  UPDATE = "UPDATE",
  DEPLOYMENT = "deployments",
  SETTINGS = "settings",
}

// https://cloud.google.com/build/docs/api/reference/rest/v1/projects.builds#status
export enum DEPLOYMENT_STATUS {
  STATUS_UNKNOWN = "STATUS_UNKNOWN",
  PENDING = "PENDING",
  QUEUED = "QUEUED",
  WORKING = "WORKING",
  SUCCESS = "SUCCESS",
  FAILURE = "FAILURE",
  INTERNAL_ERROR = "INTERNAL_ERROR",
  TIMEOUT = "TIMEOUT",
  CANCELLED = "CANCELLED",
  EXPIRE = "EXPIRE",
}

export const DEPLOYMENT_STATUS_ENUM = z.nativeEnum(DEPLOYMENT_STATUS)
export type DEPLOYMENT_STATUS_ENUM = z.infer<typeof DEPLOYMENT_STATUS_ENUM>

export interface IHeader {
  label: string
  field: SORT_FIELD
  direction: SORT_DIRECTION
}

export interface IBuildHeader {
  label: string
  field: SORT_BUILD_FIELD
  direction: SORT_DIRECTION
}

export type IFormField = {
  "Sl.no": string
  "Variable name": string
  "Display name": string
  Description: string
  Type: string
  Required: boolean
  "Default Value"?: string | number | boolean | null
  "Group/Screen"?: string
  SortOrder?: number
}

export type IUIVariable = {
  name: string
  display: string
  default: string | number | boolean | null
  required: boolean
  description: string | null
  group: number | null
  order: number | null
  options: any[] | null
  type: string
  updateSafe: boolean
}

export enum ALERT_TYPE {
  INFO,
  SUCCESS,
  WARNING,
  ERROR,
}

export interface IAlert {
  type: ALERT_TYPE
  message: string | React.ReactNode
  durationMs?: number
  closeable?: boolean
}

export interface ILogHeader {
  header: string
}

export interface ILog {
  generatedLogs: string
}

export interface IModuleCard {
  title: string
  body: JSX.Element
}

const Variables = z
  .object({
    trusted_users: z.array(z.string()).optional(),
    trusted_groups: z.array(z.string()).optional(),
    owner_users: z.array(z.string()).optional(),
    owner_groups: z.array(z.string()).optional(),
  })
  .passthrough()
export type IVariables = z.infer<typeof Variables>

export const FirestoreTimestamp = z.object({
  _nanoseconds: z.number(),
  _seconds: z.number(),
})

export type FirestoreTimestamp = z.infer<typeof FirestoreTimestamp>

export const isAdminResponseParser = z.object({
  isAdmin: z.boolean(),
})

export const EmailSchema = z.object({
  email: z.string(),
})

export const Build = z.object({
  action: z.string(),
  createdAt: FirestoreTimestamp,
  buildId: z.string(),
  user: z.string(),
  status: z.string(),
})

export const Builds = z.array(Build)
export type IBuild = z.infer<typeof Build>

export const Deployment = z.object({
  buildId: z.string().optional(),
  createdAt: FirestoreTimestamp,
  deletedAt: FirestoreTimestamp.optional(),
  deployedByEmail: z.string(),
  deploymentId: z.string(),
  id: z.string(),
  module: z.string(),
  projectId: z.string(),
  status: DEPLOYMENT_STATUS_ENUM,
  updatedAt: FirestoreTimestamp.optional(),
  variables: Variables,
  builds: Builds.optional(),
})

export const Deployments = z.array(Deployment)

export type IDeployment = z.infer<typeof Deployment>

export const TFStatus = z.object({
  buildStatus: DEPLOYMENT_STATUS_ENUM,
  tfApplyState: z.string().optional(),
})

export const Module = z.object({
  name: z.string(),
  projectId: z.string(),
  id: z.string(),
  publishedByEmail: z.string().optional(),
  variables: Variables,
  createdAt: FirestoreTimestamp,
  updatedAt: FirestoreTimestamp.optional(),
})

export const Modules = z.array(Module)

export type IModule = z.infer<typeof Module>

export type IPubSubMsg = {
  projectId: string
  module: string
  deploymentId: string
  action: DEPLOYMENT_ACTIONS
  variables: Record<string, any>
  user: string
}

export const Settings = z
  .object({
    createdAt: FirestoreTimestamp,
    createdBy: z.string(),
    id: z.string(),
    projectId: z.string(),
    variables: Variables,
  })
  .nullable()

export type ISettings = z.infer<typeof Settings>

export const Region = z.object({
  id: z.string(),
  name: z.string(),
  zones: z.array(z.string()),
})

export type IRegion = z.infer<typeof Region>

export type IGoogleCloudRegion = {
  kind: string
  id: string
  creationTimestamp: string
  name: string
  description: string
  status: string
  zones: string[]
  quotas: {
    metric: string
    limit: number
    usage: number
  }[]
  selfLink: string
  supportsPzs: boolean
}

export type IFormData = {
  [key: string]: any
}
export type IObjKeyPair = {
  [key: string]: string
}
export type IPayloadPublishData = {
  name: string
  publishedByEmail: string | null | undefined
  variables: { [key: string]: any }
}
export type IModuleFormData = {
  hasZeroGroup: boolean
  moduleName: string
  variables: { [key: string]: any }
}

export const URL = z.object({
  url: z.string(),
})

export const URLData = z.object({
  data: z.string(),
})

export const TF_OUTPUT_VARIABLE = z.object({
  sensitive: z.boolean(),
  type: z.unknown(),
  value: z.unknown(),
})

export type TF_OUTPUT_VARIABLE = z.infer<typeof TF_OUTPUT_VARIABLE>

export const TF_OUTPUT = z.record(z.string(), TF_OUTPUT_VARIABLE)

export type TF_OUTPUT = z.infer<typeof TF_OUTPUT>

export interface Dictionary<T> {
  [index: string]: T
}

export const BuildStep = z.object({
  id: z.string(),
  status: DEPLOYMENT_STATUS_ENUM,
  logsContent: z.array(z.string()).optional(),
})

export type IBuildStep = z.infer<typeof BuildStep>

export type AuthedUser = DecodedIdToken & { isAdmin: boolean; isUser: boolean }

export interface AuthedNextApiHandler extends NextApiRequest {
  user: AuthedUser
}

export type CustomNextApiHandler = (
  req: AuthedNextApiHandler,
  res: NextApiResponse,
) => void

const emailOptions = z.object({
  recipients: z.array(z.string()),
  subject: z.string(),
  mailBody: z.string(),
  credentials: z.object({
    email: z.string(),
    password: z.string(),
  }),
})
export type IEmailOptions = z.infer<typeof emailOptions>

const secretManagerRequest = z.object({
  key: z.string(),
  value: z.string(),
})

export type ISecretManagerReq = z.infer<typeof secretManagerRequest>
