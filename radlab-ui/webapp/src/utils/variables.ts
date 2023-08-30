import { IVariables, Settings } from "@/utils/types"
import axios from "axios"

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
 * Merge all objects, empty strings and arrays won't overwrite earlier full ones
 * @param {IVariables[]} args
 * @returns {IVariables}
 */
export const mergeAllSafe = (args: IVariables[]) => {
  const output = Object({})

  args.filter(Boolean).forEach((source) => {
    Object.keys(source).forEach((key) => {
      const curVal = output[key]
      const nextVal = source[key]

      if (typeof nextVal === "string") {
        if (!nextVal.length && curVal?.length) {
          // Empty string does not replace existing val
          return
        }
      }

      // Check if nextVal is Array
      if (Array.isArray(nextVal) && Array.isArray(curVal)) {
        // Don't replace a full array with an empty one
        if (!nextVal.length) return
      }

      if (
        typeof nextVal === "object" &&
        !Array.isArray(nextVal) &&
        typeof curVal === "object" &&
        !Array.isArray(curVal)
      ) {
        // Deeply merge objects
        output[key] = mergeAllSafe([curVal, nextVal])
        return
      }

      // Assign value
      output[key] = nextVal
    })
  })

  return output
}
