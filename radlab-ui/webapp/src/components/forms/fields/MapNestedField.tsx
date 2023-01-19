import { Field, FieldArray } from "formik"
import { PlusIcon, XIcon } from "@heroicons/react/outline"
import { useState } from "react"

import { IUIVariable } from "@/utils/types"

interface MapNestedField {
  variable: IUIVariable
  validate: Function
}
type IObjKeyPair = {
  [key: string]: string
}

const MapNestedField: React.FC<MapNestedField> = ({ variable, validate }) => {
  const [mapNestedParentFieldKey, setMapNestedParentFieldKey] = useState("")
  const [mapNestedFieldKey, setMapNestedFieldKey] = useState("")
  const [mapNestedFieldValue, setMapNestedFieldValue] = useState("")
  const [deleteItem, setDeleteItem] = useState("")
  const [validErrorMessage, setValidErrorMessage] = useState(null)
  const [isValidValue, setIsValidValue] = useState(false)
  const [isValidKey, setIsValidKey] = useState(false)
  const [isValidParentKey, setIsValidParentKey] = useState(false)
  const [isParentKeyEmpty, setIsParentKeyEmpty] = useState(false)

  //for map nested field type
  const handleChangeParentKey = (
    event: React.ChangeEvent<HTMLInputElement>,
  ) => {
    setMapNestedParentFieldKey(event.target.value)
    const validationError = validate(event.target.value)
    setValidErrorMessage(validationError)
    validationError ? setIsValidParentKey(false) : setIsValidParentKey(true)
  }

  const handleChangeKey = (event: React.ChangeEvent<HTMLInputElement>) => {
    setMapNestedFieldKey(event.target.value)
    const validationError = validate(event.target.value)
    setValidErrorMessage(validationError)
    validationError ? setIsValidKey(false) : setIsValidKey(true)
  }
  const handleChangeValue = (event: React.ChangeEvent<HTMLInputElement>) => {
    setMapNestedFieldValue(event.target.value)
    const validationError = validate(event.target.value)
    setValidErrorMessage(validationError)
    validationError ? setIsValidValue(false) : setIsValidValue(true)
  }

  const onSetKeyValue =
    (attributeItems: IObjKeyPair) =>
    (event: React.MouseEvent<HTMLButtonElement>) => {
      event.preventDefault()
      if (mapNestedFieldKey && mapNestedFieldValue) {
        const checkLastKey =
          Object.keys(attributeItems)[Object.keys(attributeItems).length - 1]
        //@ts-ignore
        attributeItems[checkLastKey][mapNestedFieldKey] = mapNestedFieldValue
        setIsParentKeyEmpty(false)
      }
      setMapNestedFieldKey("")
      setMapNestedFieldValue("")
      setIsValidKey(false)
      setIsValidValue(false)
    }

  const onSetParentKeyValue =
    (attributeItems: IObjKeyPair) =>
    (event: React.MouseEvent<HTMLButtonElement>) => {
      event.preventDefault()
      if (mapNestedParentFieldKey) {
        // @ts-ignore
        attributeItems[mapNestedParentFieldKey] = {}
        setIsParentKeyEmpty(true)
      }
      setMapNestedParentFieldKey("")
      setMapNestedFieldKey("")
      setMapNestedFieldValue("")
      setIsValidParentKey(false)
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
                (map_data: any) => (
                  <div
                    key={map_data}
                    className="badge badge-info gap-1 mt-2 w-full h-auto py-1 px-2 md:py-1 md:px-4"
                  >
                    <span
                      className="text-xs w-full"
                      style={{ overflowWrap: "anywhere" }}
                    >
                      <span className="text-sm">{map_data} : </span>
                      {Object.keys(values[variable.name][map_data]).map(
                        (map_inner_key, indexInner) => (
                          <span key={map_inner_key}>
                            {indexInner ? ", " : ""}
                            {map_inner_key}=
                            {values[variable.name][map_data][map_inner_key]}
                          </span>
                        ),
                      )}
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
                <Field
                  name="map_set_parent_key"
                  className="input w-full mr-1"
                  value={mapNestedParentFieldKey}
                  onChange={handleChangeParentKey}
                />
                <button
                  type="button"
                  className="btn btn-outline btn-secondary ml-2"
                  onClick={onSetParentKeyValue(values[variable.name])}
                  disabled={!isValidParentKey || isParentKeyEmpty}
                >
                  <PlusIcon className="h-6 w-6" />
                </button>
              </div>
              <div className="flex mt-1">
                <input type="hidden" value={deleteItem} />
                <Field
                  name="map_set_key"
                  className="input w-full mr-1"
                  value={mapNestedFieldKey}
                  onChange={handleChangeKey}
                />
                <Field
                  name="map_set_value"
                  className="input w-full ml-1"
                  value={mapNestedFieldValue}
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

export default MapNestedField
