import { Field, FieldArray } from "formik"
import { PlusIcon, XIcon } from "@heroicons/react/outline"
import { useState } from "react"
import { IUIVariable } from "@/utils/types"

interface SetField {
  variable: IUIVariable
}

const SetField: React.FC<SetField> = ({ variable }) => {
  const [formFieldValue, setFormFieldValue] = useState("")

  const inputHandler = (event: React.ChangeEvent<HTMLInputElement>) => {
    setFormFieldValue(event.target.value)
  }

  const onSetValue =
    (FieldArrayPropsPush: Function) =>
    (event: React.MouseEvent<HTMLButtonElement>) => {
      event.preventDefault()
      if (formFieldValue) {
        FieldArrayPropsPush(formFieldValue)
      }
      setFormFieldValue("")
    }

  const handleKeyboardEvent =
    (FieldArrayPropsPush: Function) =>
    (e: React.KeyboardEvent<HTMLInputElement>) => {
      if (e.key === "Enter") {
        e.preventDefault()
        if (formFieldValue) {
          FieldArrayPropsPush(formFieldValue)
        }
        setFormFieldValue("")
      }
    }

  return (
    <div className="form-control" key={variable.name}>
      <label htmlFor={variable.name}>{variable.display}</label>
      <FieldArray name={variable.name}>
        {(FieldArrayProps) => {
          const { push, remove, form } = FieldArrayProps
          const { values } = form
          const unique = [...new Set(values[variable.name])]
          values[variable.name] = unique
          return (
            <div>
              {values[variable.name].map((setvalue: string, index: number) => (
                <div
                  key={index}
                  className="badge badge-info gap-1 mt-2 w-auto h-auto py-1 px-2 md:py-1 md:px-4"
                >
                  <span
                    className="text-xs w-11/12"
                    style={{ overflowWrap: "anywhere" }}
                  >
                    {setvalue}
                  </span>
                  <XIcon
                    onClick={() => remove(index)}
                    className="h-4 w-4 cursor-pointer"
                  />
                </div>
              ))}
              <div className="flex mt-1">
                <Field
                  name="setfield"
                  className="input w-full"
                  value={formFieldValue}
                  onChange={inputHandler}
                  onKeyDown={handleKeyboardEvent(push)}
                />
                <button
                  type="button"
                  className="btn btn-outline btn-secondary ml-2"
                  onClick={onSetValue(push)}
                >
                  <PlusIcon className="h-6 w-6" />
                </button>
              </div>
            </div>
          )
        }}
      </FieldArray>
      <div className="text-sm text-faint mt-1">{variable.description}</div>
    </div>
  )
}

export default SetField
