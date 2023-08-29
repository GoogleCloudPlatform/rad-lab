import { IVariables, Settings } from "@/utils/types"
import axios from "axios"
import { mergeAll } from "ramda"

/**
 * Fetch the admin settings for a given GCP project
 * @param {string} gcpProjectId
 * @returns {Settings | null}
 */
export const fetchAdminSettings = async (gcpProjectId: string) => {
  try {
    const res = await axios.get(`/api/settings?gcpProjectId=${gcpProjectId}`)
    const settings = Settings.parse(res.data.settings)
    return settings
  } catch (error) {
    return null
  }
}

/**
 * Merge all objects in the array, removing any keys with empty string values
 * @param {IVariables[]} args
 * @returns {IVariables}
 */
export const mergeAllSafe = (args: IVariables[]) =>
  mergeAll(args.map(removeEmptyStrings))

/**
 * Remove any keys with empty string values from the object
 * @param {IVariables} obj
 * @returns {IVariables}
 */
export const removeEmptyStrings = (obj: IVariables) => {
  return Object.keys(obj).reduce((o, key) => {
    if (o[key] === "") {
      delete o[key]
    }
    return o
  }, obj)
}
