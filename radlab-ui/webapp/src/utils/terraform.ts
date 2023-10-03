// @ts-ignore
import * as hclParse from "hcl2-parser"
import groupBy from "lodash/groupBy"
import startCase from "lodash/startCase"
import { IUIVariable, IObjKeyPair, IFormData } from "@/utils/types"
import axios from "axios"
import { FormikValues } from "formik"

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
const MANDATORY_MATCHER = /mandatory/gi
const DEPENDSON_MATCHER = /dependson\=\((.*)\)/gi

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
  let mandatory: boolean = false
  let dependsOn: string | null = null

  if (!varDescription) {
    return {
      description,
      group,
      order,
      options,
      updateSafe,
      mandatory,
      dependsOn,
    }
  }

  // Get the full meta tag
  const fullMeta: string =
    [...varDescription.matchAll(META_MATCHER)]?.[0]?.[0]?.trim() || ""
  if (!fullMeta) {
    return {
      description,
      group,
      order,
      options,
      updateSafe,
      mandatory,
      dependsOn,
    }
  }

  // Strip the meta tag from the description
  description = varDescription.replace(fullMeta, "").trim()

  // Get the inner portion of the meta tag
  const meta: string =
    [...varDescription.matchAll(META_MATCHER)]?.[0]?.[1]?.trim() || ""
  if (!meta) {
    // No UIMeta tag defined
    return {
      description,
      group,
      order,
      options,
      updateSafe,
      mandatory,
      dependsOn,
    }
  }

  updateSafe = !![...meta.matchAll(SAFE_UPDATE_MATCHER)].length

  mandatory = !![...meta.matchAll(MANDATORY_MATCHER)].length

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

  dependsOn = [...meta.matchAll(DEPENDSON_MATCHER)]?.[0]?.[1]?.trim() ?? null

  return {
    description,
    group,
    order,
    options,
    updateSafe,
    mandatory,
    dependsOn,
  }
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

  const {
    description,
    group,
    order,
    options,
    updateSafe,
    mandatory,
    dependsOn,
  } = parseUIMeta(hclVar.description ?? null, hclVar.type)

  return {
    name,
    display: startCase(name),
    description,
    type: formatType(hclVar.type),
    default: hclVar.default
      ? hclVar.default
      : formatType(hclVar.type) === "bool"
      ? false
      : hclVar.default === ""
      ? ""
      : null,
    required: mandatory,
    group,
    order,
    options,
    updateSafe,
    mandatory,
    dependsOn,
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

export const checkDependsOnValid = (
  dependsOnVarData: string | null,
  userAnswerData: FormikValues,
) => {
  if (dependsOnVarData) {
    const dependsOnDataOperatorFormats = dependsOnVarData
      .replaceAll("&&", " && ")
      .replaceAll("||", " || ")

    const dependsOnDataAnswerMatchRes = dependsOnDataOperatorFormats
      .split(" ")
      .map((dependsOnDataOperatorFormat) => {
        const checkDependsNameVar = dependsOnDataOperatorFormat.split("==")
        let getwithAnswerMatch
        if (checkDependsNameVar.length === 2) {
          //@ts-ignore
          getwithAnswerMatch = `${userAnswerData[checkDependsNameVar[0]]} == ${
            checkDependsNameVar[1]
          }`
        } else {
          getwithAnswerMatch = checkDependsNameVar[0]
        }

        return getwithAnswerMatch
      })
      .join(" ")

    const formatDependsOnDataAnswerMatchRes = `(${dependsOnDataAnswerMatchRes.replaceAll(
      " && ",
      ") && (",
    )})`

    const dependsOnDataAnswerMatchEvalute = eval(
      formatDependsOnDataAnswerMatchRes,
    )

    return dependsOnDataAnswerMatchEvalute
  } else {
    return false
  }
}

export const formatRelevantVariables = (
  formVariablesData: IUIVariable[],
  currentAnswerValueData: FormikValues,
) => {
  const allNonDependsVars = formVariablesData.filter(
    (formVariableData) => !formVariableData.dependsOn,
  )
  const allDependsVars = formVariablesData.filter(
    (formVariableData) => formVariableData.dependsOn,
  )

  const findDependentVars = allDependsVars.filter((dependsVars) => {
    const isDependsOnValid = checkDependsOnValid(
      dependsVars.dependsOn,
      currentAnswerValueData,
    )

    if (isDependsOnValid) {
      return dependsVars
    } else {
      return null
    }
  })

  const allRelevantFormVariables = allNonDependsVars.concat(
    findDependentVars !== undefined && findDependentVars.length
      ? findDependentVars
      : [],
  )

  return allRelevantFormVariables
}
