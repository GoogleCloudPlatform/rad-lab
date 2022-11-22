import { Field, ErrorMessage } from "formik"

import { IUIVariable } from "@/utils/types"

interface IStringField {
  variable: IUIVariable
  validate: Function
}

const StringField: React.FC<IStringField> = ({ variable, validate }) => {
  return (
    <div className="form-control" key={variable.name}>
      <label htmlFor={variable.name}>{variable.display}</label>
      {variable.options ? (
        <Field
          as="select"
          id={variable.name}
          name={variable.name}
          className="input"
          validate={validate}
        >
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
          id={variable.name}
          name={variable.name}
          className="input"
          validate={validate}
        />
      )}
      <div className="text-error text-xs mt-1">
        <ErrorMessage name={variable.name} />
      </div>
      <div className="text-sm text-faint mt-1">{variable.description}</div>
    </div>
  )
}

export default StringField
