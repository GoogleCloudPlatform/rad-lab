import sortBy from "lodash/sortBy"
import { FormikStep } from "@/components/forms/FormikStepper"
import { IUIVariable } from "@/utils/types"
import StringField from "@/components/forms/fields/StringField"

interface IDefaultStepCreatorProps {
  variableList: IUIVariable[]
  idx: number
}

type IFieldValidateValue = { value: string | number | boolean }

const DefaultStepCreator: React.FC<IDefaultStepCreatorProps> = ({
  variableList,
  idx,
}) => {
  const sortedList = sortBy(variableList, "order")

  const validateRequired = (value: IFieldValidateValue) => {
    let error
    if (!value) {
      error = "Required"
    }
    return error
  }

  const renderControls = (variable: IUIVariable) => {
    return <StringField variable={variable} validate={validateRequired} />
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
