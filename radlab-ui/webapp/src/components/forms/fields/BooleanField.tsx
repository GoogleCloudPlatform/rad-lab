import { Field } from "formik"

import { IUIVariable } from "@/utils/types"

interface BooleanField {
  variable: IUIVariable
}

const BooleanField: React.FC<BooleanField> = ({ variable }) => {
  return (
    <div className="form-control" key={variable.name}>
      <div className="flex justify-between">
        <label
          className="w-full flex justify-between font-semibold text-sm text-dim"
          htmlFor={variable.name}
        >
          <div>{variable.display}</div>
          <Field
            id={variable.name}
            type="checkbox"
            className="checkbox checkbox-primary"
            name={variable.name}
          />
        </label>
      </div>
      <div className="text-sm text-faint mt-1">{variable.description}</div>
    </div>
  )
}

export default BooleanField
