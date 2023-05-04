export const envOrFail = (
  name: string,
  value: string | undefined,
  fallback?: string,
): string => {
  // Must explicitly pass in process.env.VAR_NAME otherwise NextJS won't load it
  // Can't do dynamic variables like: process.env[name]
  // https://nextjs.org/docs/basic-features/environment-variables
  if (typeof value === "undefined" || value === "") {
    if (fallback) {
      console.warn(`${name} was not set. Defaulting to ${fallback}`)
      return fallback
    }
    throw new Error(`${name} is not set`)
  }
  return value
}
