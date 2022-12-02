import { validators } from "@/utils/validation"

const validationCheck = (variableName: string, value: string) => {
  const checks = validators[variableName]
  const validateStatus = checks?.every(({ fn }) => {
    const valid = fn(value)
    return valid
  })
  return validateStatus
}

describe("validation util", () => {
  it("good project ID", () => {
    const project_id_prefix = validationCheck(
      "project_id_prefix",
      "projectname-project",
    )
    expect(project_id_prefix).toBe(true)
  })

  it("bad project ID", () => {
    const project_id_prefix = validationCheck(
      "project_id_prefix",
      "projectname-",
    )
    expect(project_id_prefix).not.toBe(true)
  })
})
