import { Field, ErrorMessage } from "formik"

import { IUIVariable } from "@/utils/types"

interface INumberField {
  variable: IUIVariable
  validate: Function
}

const NumberField: React.FC<INumberField> = ({ variable, validate }) => {
  return (
    <div className="form-control" key={variable.name}>
      <label htmlFor={variable.name}>{variable.display}</label>
      {variable.options ? (
        <Field as="select" name={variable.name} className="input">
          {variable.options.map((option, index) => {
            return (
              <option key={index} value={option}>
                {option}
              </option>
            )
          })}
        </Field>
      ) : (
        <Field
          type="number"
          min="0"
          id={variable.name}
          name={variable.name}
          className="input"
          validate={validate}
          //@ts-ignore
          onWheel={(e) => e.target.blur()}
        />
      )}
      <div className="text-error text-xs mt-1">
        <ErrorMessage name={variable.name} />
      </div>
      <div className="text-sm text-faint mt-1">{variable.description}</div>
    </div>
  )
}

export default NumberField
