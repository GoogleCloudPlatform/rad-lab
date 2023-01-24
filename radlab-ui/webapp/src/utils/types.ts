import React from "react"
import zod from "zod"

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

export const DEPLOYMENT_STATUS_ENUM = zod.nativeEnum(DEPLOYMENT_STATUS)
export type DEPLOYMENT_STATUS_ENUM = zod.infer<typeof DEPLOYMENT_STATUS_ENUM>

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

const Variables = zod.object({}).passthrough()

export const FirestoreTimestamp = zod.object({
  _nanoseconds: zod.number(),
  _seconds: zod.number(),
})

export type FirestoreTimestamp = zod.infer<typeof FirestoreTimestamp>

export const isAdminResponseParser = zod.object({
  isAdmin: zod.boolean(),
})

export const EmailSchema = zod.object({
  email: zod.string(),
})

export const Build = zod.object({
  action: zod.string(),
  createdAt: FirestoreTimestamp,
  buildId: zod.string(),
  user: zod.string(),
  status: zod.string(),
})

export const Builds = zod.array(Build)
export type IBuild = zod.infer<typeof Build>

export const Deployment = zod.object({
  buildId: zod.string().optional(),
  createdAt: FirestoreTimestamp,
  deletedAt: FirestoreTimestamp.optional(),
  deployedByEmail: zod.string(),
  deploymentId: zod.string(),
  id: zod.string(),
  module: zod.string(),
  projectId: zod.string(),
  status: DEPLOYMENT_STATUS_ENUM,
  updatedAt: FirestoreTimestamp.optional(),
  variables: Variables,
  builds: Builds.optional(),
})

export const Deployments = zod.array(Deployment)

export type IDeployment = zod.infer<typeof Deployment>

export const TFStatus = zod.object({
  buildStatus: DEPLOYMENT_STATUS_ENUM,
  tfApplyState: zod.string().optional(),
})

export const Module = zod.object({
  name: zod.string(),
  projectId: zod.string(),
  id: zod.string(),
  publishedByEmail: zod.string().optional(),
  variables: Variables,
  createdAt: FirestoreTimestamp,
  updatedAt: FirestoreTimestamp.optional(),
})

export const Modules = zod.array(Module)

export type IModule = zod.infer<typeof Module>

export type IPubSubMsg = {
  projectId: string
  module: string
  deploymentId: string
  action: DEPLOYMENT_ACTIONS
  variables: Record<string, any>
  user: string
}

export const Settings = zod
  .object({
    createdAt: FirestoreTimestamp,
    createdBy: zod.string(),
    id: zod.string(),
    projectId: zod.string(),
    variables: Variables,
  })
  .nullable()

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

export const URL = zod.object({
  url: zod.string(),
})

export const URLData = zod.object({
  data: zod.string(),
})

export const TF_OUTPUT_VARIABLE = zod.object({
  sensitive: zod.boolean(),
  type: zod.unknown(),
  value: zod.unknown(),
})

export type TF_OUTPUT_VARIABLE = zod.infer<typeof TF_OUTPUT_VARIABLE>

export const TF_OUTPUT = zod.record(zod.string(), TF_OUTPUT_VARIABLE)

export type TF_OUTPUT = zod.infer<typeof TF_OUTPUT>

export interface Dictionary<T> {
  [index: string]: T
}
