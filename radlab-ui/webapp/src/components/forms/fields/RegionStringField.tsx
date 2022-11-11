import { Field, ErrorMessage } from "formik"
import { IUIVariable } from "@/utils/types"

interface IRegionStringFieldProps {
  variable: IUIVariable
  validateRequired: Function
  onChangeRegion: Function
}

const RegionStringField: React.FC<IRegionStringFieldProps> = ({
  variable,
  validateRequired,
  onChangeRegion,
}) => {
  return (
    <div className="form-control" key={variable.name}>
      <label htmlFor={variable.name}>{variable.display}</label>
      {variable.options ? (
        <Field
          as="select"
          id={variable.name}
          name={variable.name}
          className="input"
          validate={validateRequired}
          onChange={onChangeRegion}
        >
          {variable.options.map((option) => {
            return (
              <option key={option} value={option}>
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
          validate={validateRequired}
        />
      )}
      <div className="text-error text-xs mt-1">
        <ErrorMessage name={variable.name} />
      </div>
      <div className="text-sm text-faint mt-1">{variable.description}</div>
    </div>
  )
}

export default RegionStringField
