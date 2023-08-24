import { FormikStep } from "@/components/forms/FormikStepper"
import BooleanField from "@/components/forms/fields/BooleanField"
import ListField from "@/components/forms/fields/ListField"
import MapField from "@/components/forms/fields/MapField"
import MapNestedField from "@/components/forms/fields/MapNestedField"
import NumberField from "@/components/forms/fields/NumberField"
import RegionStringField from "@/components/forms/fields/RegionStringField"
import SetField from "@/components/forms/fields/SetField"
import StringField from "@/components/forms/fields/StringField"
import ZoneStringField from "@/components/forms/fields/ZoneStringField"
import { IUIVariable } from "@/utils/types"
import { validators } from "@/utils/validation"
import { useField } from "formik"
import sortBy from "lodash/sortBy"
import startCase from "lodash/startCase"

interface StepCreator {
  variableList: IUIVariable[]
  idx: number
}

const TF_PRIMITIVES = ["number", "string"]

type IFieldValidateValue = { value: string | number | boolean }

const StepCreator: React.FC<StepCreator> = ({ variableList, idx }) => {
  const sortedList = sortBy(variableList, "order")

  const validate = (variable: IUIVariable) => (value: IFieldValidateValue) => {
    // Type checks
    if (
      variable.type === "number" &&
      (!Number.isFinite(Number(value)) || Number(value) < 0)
    )
      return `Not a valid number`

    // Field format checks
    const checks = validators[variable.name]
    if (checks) {
      let validateMessage = ""
      checks.every(({ message, fn }) => {
        const valid = fn(value)
        if (!valid) validateMessage = message
        return valid
      })
      if (validateMessage) return validateMessage
    }

    // Required checks
    if (!variable.required || value || value === 0) return null
    return `A value for ${startCase(variable.name)} is required`
  }

  const validateRequired = (value: IFieldValidateValue) => {
    let error
    if (!value) {
      error = "Required"
    }
    return error
  }
  const renderControls = (
    variable: IUIVariable,
    sortedVariables: IUIVariable[],
    i: number,
  ) => {
    if (variable.type.slice(0, 10) === "map(object") {
      return (
        <MapNestedField variable={variable} validate={validate(variable)} />
      )
    }

    if (variable.name.startsWith("region")) {
      return (
        <RegionStringField variable={variable} validate={validate(variable)} />
      )
    }

    if (variable.name.startsWith("zone")) {
      const prevVariable = sortedVariables[i - 1]

      // If the zone has a variable immediately before it for zone
      // use that to determine the region and its zones, else show all zones
      let region = undefined
      if (prevVariable?.name.startsWith("region")) {
        const [_, fieldMeta] = useField(prevVariable.name)
        region = fieldMeta.value ?? prevVariable.default
      }

      return (
        <ZoneStringField
          key={idx}
          variable={variable}
          validate={validate(variable)}
          region={region}
        />
      )
    }

    switch (variable.type) {
      case "string":
        return <StringField variable={variable} validate={validate(variable)} />
      case "bool":
        return <BooleanField variable={variable} />
      case "number":
        return <NumberField variable={variable} validate={validate(variable)} />
      case "set(string)":
      case "set(number)":
        return <SetField variable={variable} />
      case "list(string)":
      case "list(number)":
        return <ListField variable={variable} />
      case "map":
      case "map(string)":
        return <MapField variable={variable} validate={validate(variable)} />
      default:
        return <StringField variable={variable} validate={validateRequired} />
    }
  }

  return (
    <FormikStep label={(idx + 1).toFixed(0)}>
      <div className="flex-wrap">
        {sortedList.map((variable, i) => (
          <div className="relative" key={variable.name}>
            {variable.required && TF_PRIMITIVES.includes(variable.type) && (
              <div className="absolute -left-3 text-error text-xl">*</div>
            )}
            {renderControls(variable, sortedList, i)}
          </div>
        ))}
      </div>
    </FormikStep>
  )
}

export default StepCreator
