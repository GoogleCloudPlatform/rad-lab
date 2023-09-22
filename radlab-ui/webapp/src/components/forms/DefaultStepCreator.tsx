import sortBy from "lodash/sortBy"
import { FormikStep } from "@/components/forms/FormikStepper"
import { IUIVariable } from "@/utils/types"
import StringField from "@/components/forms/fields/StringField"
import BooleanField from "@/components/forms/fields/BooleanField"
import { useFormikContext } from "formik"
import { useEffect } from "react"

interface IDefaultStepCreatorProps {
  variableList: IUIVariable[]
  idx: number
  handleChangeValues: Function
}

type IFieldValidateValue = { value: string | number | boolean }

const DefaultStepCreator: React.FC<IDefaultStepCreatorProps> = ({
  variableList,
  idx,
  handleChangeValues,
}) => {
  const sortedList = sortBy(variableList, "order")

  const validateRequired = (value: IFieldValidateValue) => {
    let error
    if (!value) {
      error = "Required"
    }
    return error
  }

  const { values } = useFormikContext()

  useEffect(() => {
    handleChangeValues(values)
  }, [values])

  const renderControls = (variable: IUIVariable) => {
    switch (variable.type) {
      case "string":
        return <StringField variable={variable} validate={validateRequired} />
      case "bool":
        return <BooleanField variable={variable} />
      default:
        return <StringField variable={variable} validate={validateRequired} />
    }
  }

  return (
    <FormikStep label={(idx + 1).toFixed(0)}>
      <div className="grid grid-flow-row">
        {sortedList.map((elem) => (
          <div key={elem.name}>{renderControls(elem)}</div>
        ))}
      </div>
    </FormikStep>
  )
}

export default DefaultStepCreator
