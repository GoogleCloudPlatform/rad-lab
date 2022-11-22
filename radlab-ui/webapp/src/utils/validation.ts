type ValidatorFn = (val: any) => boolean
type Validator = {
  fn: ValidatorFn
  message: string
}
type VariableName = string
type FormValidators = Record<VariableName, Validator[]>

const projectIdPatternValidation = (value: VariableName) => {
  const regex = new RegExp("^[a-z][a-z0-9-]{4,23}[a-z0-9]$")
  return regex.test(value)
}

const billingBudgetLabelPatternValidation = (value: VariableName) => {
  const regex = new RegExp("^[a-z][a-z0-9-_]{0,63}$")
  return regex.test(value)
}

export const validators: FormValidators = {
  project_name: [
    {
      message:
        "Invalid Project Name. Must be lowercase letters, numbers or hyphens; between 6-25 characters; must start with a letter and cannot end with a hyphen",
      fn: projectIdPatternValidation,
    },
  ],
  project_id_prefix: [
    {
      message:
        "Invalid Project ID. Must be lowercase letters, numbers or hyphens; between 6-25 characters; must start with a letter and cannot end with a hyphen",
      fn: projectIdPatternValidation,
    },
  ],
  billing_budget_labels: [
    {
      message:
        "Invalid Billing Budget Labels. Must be lowercase letters, numbers, underscores or hyphens; between 0-63 characters; must start with a letter",
      fn: billingBudgetLabelPatternValidation,
    },
  ],
}
