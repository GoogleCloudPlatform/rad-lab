import { Field, FieldArray } from "formik"
import { PlusIcon, XIcon } from "@heroicons/react/outline"
import { useState } from "react"

import { IUIVariable } from "@/utils/types"

interface MapField {
  variable: IUIVariable
  validate: Function
}
type IObjKeyPair = {
  [key: string]: string
}

const MapField: React.FC<MapField> = ({ variable, validate }) => {
  const [mapFieldKey, setMapFieldKey] = useState("")
  const [mapFieldValue, setMapFieldValue] = useState("")
  const [deleteItem, setDeleteItem] = useState("")
  const [validErrorMessage, setValidErrorMessage] = useState(null)
  const [isValidValue, setIsValidValue] = useState(false)
  const [isValidKey, setIsValidKey] = useState(false)

  //for map field type
  const handleChangeKey = (event: React.ChangeEvent<HTMLInputElement>) => {
    setMapFieldKey(event.target.value)
    const validationError = validate(event.target.value)
    setValidErrorMessage(validationError)
    validationError ? setIsValidKey(false) : setIsValidKey(true)
  }
  const handleChangeValue = (event: React.ChangeEvent<HTMLInputElement>) => {
    setMapFieldValue(event.target.value)
    const validationError = validate(event.target.value)
    setValidErrorMessage(validationError)
    validationError ? setIsValidValue(false) : setIsValidValue(true)
  }

  const onSetKeyValue =
    (attributeItems: IObjKeyPair) =>
    (event: React.MouseEvent<HTMLButtonElement>) => {
      event.preventDefault()
      if (mapFieldKey && mapFieldValue) {
        attributeItems[mapFieldKey] = mapFieldValue
      }
      setMapFieldKey("")
      setMapFieldValue("")
      setIsValidKey(false)
      setIsValidValue(false)
    }

  const handleRemove =
    (attributeItems: IObjKeyPair, attributeKey: string) =>
    (event: React.MouseEvent<HTMLButtonElement>) => {
      event.preventDefault()
      delete attributeItems[attributeKey]
      setDeleteItem(attributeKey)
    }

  return (
    <div className="form-control" key={variable.name}>
      <label htmlFor={variable.name}>{variable.display}</label>
      <FieldArray name={variable.name}>
        {(FieldArrayProps) => {
          const { form } = FieldArrayProps
          const { values } = form
          return (
            <div>
              {Object.keys(values[variable.name]).map(
                (map_data: string, index: number) => (
                  <div
                    key={index}
                    className="badge badge-info gap-1 mt-2 w-auto h-auto py-1 px-2 md:py-1 md:px-4"
                  >
                    <span
                      className="text-xs w-11/12"
                      style={{ overflowWrap: "anywhere" }}
                    >
                      {map_data} = {values[variable.name][map_data]}
                    </span>
                    <button
                      type="button"
                      onClick={handleRemove(values[variable.name], map_data)}
                    >
                      <XIcon className="h-4 w-4 cursor-pointer" />
                    </button>
                  </div>
                ),
              )}
              <div className="flex mt-1">
                <input type="hidden" value={deleteItem} />
                <Field
                  name="map_set_key"
                  className="input w-full mr-1"
                  value={mapFieldKey}
                  onChange={handleChangeKey}
                />
                <Field
                  name="map_set_value"
                  className="input w-full ml-1"
                  value={mapFieldValue}
                  onChange={handleChangeValue}
                />
                <button
                  type="button"
                  className="btn btn-outline btn-secondary ml-2"
                  onClick={onSetKeyValue(values[variable.name])}
                  disabled={!isValidKey || !isValidValue}
                >
                  <PlusIcon className="h-6 w-6" />
                </button>
              </div>
            </div>
          )
        }}
      </FieldArray>
      <div className="text-error text-xs mt-1">{validErrorMessage}</div>
      <div className="text-sm text-faint mt-1">{variable.description}</div>
    </div>
  )
}

export default MapField
