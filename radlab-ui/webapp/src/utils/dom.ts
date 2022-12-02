/**
 * Pass many strings and get one back. Useful for dynamic classNames
 * @param classes n strings
 * @returns A concatenated string of classes
 */
export const classNames = (...classes: string[]) =>
  classes.filter(Boolean).join(" ")
