// @ts-ignore
import * as hclParse from "hcl2-parser"
import groupBy from "lodash/groupBy"
import startCase from "lodash/startCase"
import { IUIVariable, IObjKeyPair, IFormData } from "@/utils/types"
import axios from "axios"

type IHCLVariable = {
  type: string
  default?: string | number | boolean | null
  description?: string
}

type IParsedHCLVariables = Record<string, [IHCLVariable]>

type IRawParsed = [{ variable: IParsedHCLVariables }]

const META_MATCHER = /\{\{UIMeta(.*)\}\}/gi
const GROUP_MATCHER = /group\=([\d]+)/gi
const ORDER_MATCHER = /order\=([\d]+)/gi
const OPTIONS_MATCHER = /options\=([^\s}]+)/gi
const SAFE_UPDATE_MATCHER = /updatesafe/gi

const formatType = (type: string) => type.replace(/[${}]/g, "")

/**
 * Parses a custom UIMeta tag
 * @param varDescription The Terraform variable description
 * @returns An object containing the parsed description, group, order, and options
 */
const parseUIMeta = (varDescription: string | null, type = "string") => {
  let description: string | null = varDescription
  let group: number | null = null
  let order: number | null = null
  let options: any[] | null = null
  let updateSafe: boolean = false // Assume destructive

  if (!varDescription) {
    return { description, group, order, options, updateSafe }
  }

  // Get the full meta tag
  const fullMeta: string =
    [...varDescription.matchAll(META_MATCHER)]?.[0]?.[0]?.trim() || ""
  if (!fullMeta) {
    return { description, group, order, options, updateSafe }
  }

  // Strip the meta tag from the description
  description = varDescription.replace(fullMeta, "").trim()

  // Get the inner portion of the meta tag
  const meta: string =
    [...varDescription.matchAll(META_MATCHER)]?.[0]?.[1]?.trim() || ""
  if (!meta) {
    // No UIMeta tag defined
    return { description, group, order, options, updateSafe }
  }

  updateSafe = !![...meta.matchAll(SAFE_UPDATE_MATCHER)].length

  const grp = [...meta.matchAll(GROUP_MATCHER)]?.[0]?.[1]?.trim()
  group = grp ? parseInt(grp) : null
  if (group !== null && isNaN(group))
    throw new Error(`group is not a number: ${meta}`)

  const ord = [...meta.matchAll(ORDER_MATCHER)]?.[0]?.[1]?.trim()
  order = ord ? parseInt(ord) : null
  if (order !== null && isNaN(order))
    throw new Error(`order is not a number: ${meta}`)

  options =
    [...meta.matchAll(OPTIONS_MATCHER)]?.[0]?.[1]?.trim()?.split(",") ?? null

  if (options) {
    options = options.map((o) => {
      if (type === "number") {
        return parseInt(o)
      }
      return o
    })
  }

  return { description, group, order, options, updateSafe }
}

/**
 * Map an HCL variable to a RAD Lab UI variable
 * @param value: an Array containing the variable name and an Array with the HCL Var
 * @returns the IUIVariable
 */
const mapHclToUIVar = (
  value: [string, [IHCLVariable]],
  _index: number,
  _array: [string, [IHCLVariable]][],
): IUIVariable => {
  const [name, hclVars] = value
  const hclVar = hclVars[0]

  const { description, group, order, options, updateSafe } = parseUIMeta(
    hclVar.description ?? null,
    hclVar.type,
  )

  return {
    name: name,
    display: startCase(name),
    description,
    type: formatType(hclVar.type),
    default: hclVar.default
      ? hclVar.default
      : formatType(hclVar.type) === "bool"
      ? false
      : null,
    // In TF, desription = "" is how we say it's optional
    required:
      typeof hclVar.default === "undefined" ||
      hclVar.default === "" ||
      hclVar.default !== "",
    group,
    order,
    options,
    updateSafe,
  }
}

/**
 * Parse a variables.tf file into a RAD Lab UI variable list
 * @param body: string The body of the HCL variables.tf file
 * @returns An array of UI variables
 */
export const parseVarsFile = (body: string) => {
  const parseData: IRawParsed = hclParse.parseToObject(body)
  const variables = parseData[0].variable
  return Object.entries(variables).map(mapHclToUIVar)
}

export const groupVariables = (variableList: IUIVariable[]) =>
  groupBy(variableList, "group")

/**
 * Represents the formik field default value
 **/
export const initialFormikData = (data: IFormData) => {
  const initialObjData: IObjKeyPair = {}
  Object.keys(data).forEach((formVariables) => {
    const title = data[formVariables].name
    let defaultValue = formDefaultValidation(
      data[formVariables].default,
      data[formVariables].type,
    )
    initialObjData[title] = defaultValue
  })
  return initialObjData
}

const formDefaultValidation = (defaultValue: any, type: string | boolean) => {
  if (
    defaultValue === null &&
    (type === "list(string)" ||
      type === "list(number)" ||
      type === "set(number)" ||
      type === "set(string)")
  ) {
    defaultValue = []
  } else if (
    defaultValue === null &&
    (type === "map(string)" || type === "map")
  ) {
    defaultValue = {}
  } else if (defaultValue === null && type === "bool") {
    defaultValue = false
  } else if (defaultValue === null && type === "number") {
    defaultValue = 0
  } else if (defaultValue === null) {
    defaultValue = ""
  }
  return defaultValue
}

// selected modules form zero group variable set from git variable.tf
export const modulesHasZeroData = async (selctedModules: string[]) => {
  const formatModulesVarDataArr = await Promise.all(
    selctedModules.map(async (moduleName: string) => {
      const moduleVariableData = await checkModuleVariablesZero(moduleName)
      const hasZeroGroup = !!moduleVariableData?.length
      return {
        moduleName: moduleName,
        hasZeroGroup: hasZeroGroup,
        variables: { ...moduleVariableData },
      }
    }),
  )
  // only pass to form zero group varuiables modules
  const onlyZeroGroupModules = formatModulesVarDataArr.filter(
    (mod) => !!mod.hasZeroGroup,
  )

  return onlyZeroGroupModules
}
//Call the git api and assign the module form variables
const checkModuleVariablesZero = async (moduleName: string) => {
  const apiUrl = `/api/github/${moduleName}/variables`

  const returnModuleVariableData = await axios
    .get(apiUrl)
    .then((response) => {
      let decodeToString = Buffer.from(
        response.data.variables.content,
        "base64",
      ).toString()
      const parseData = parseVarsFile(decodeToString)
      const zeroGroupData = parseData.filter((v) => v.group === 0)
      return zeroGroupData
    })
    .catch((error) => {
      console.error(error)
    })
  return returnModuleVariableData
}
