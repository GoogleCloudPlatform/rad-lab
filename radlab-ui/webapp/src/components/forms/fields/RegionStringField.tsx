import { Field, ErrorMessage } from "formik"
import { IUIVariable } from "@/utils/types"
import { useEffect, useState } from "react"
import { cloudLocationStore } from "@/store"

interface IRegionStringFieldProps {
  variable: IUIVariable
  validate: Function
}

const RegionStringField: React.FC<IRegionStringFieldProps> = ({
  variable,
  validate,
}) => {
  const [regions, setRegions] = useState<string[]>([])
  const cloudLocation = cloudLocationStore((state) => state.cloudLocation)

  useEffect(() => {
    cloudLocation.regionNames.then((r) => {
      setRegions(["", ...r])
    })
  }, [])

  return (
    <div className="form-control" key={variable.name}>
      <label htmlFor={variable.name}>{variable.display}</label>
      <Field
        as="select"
        id={variable.name}
        name={variable.name}
        className="input"
        validate={validate}
      >
        {regions.map((region) => {
          return (
            <option key={region} value={region}>
              {region}
            </option>
          )
        })}
      </Field>
      <div className="text-error text-xs mt-1">
        <ErrorMessage name={variable.name} />
      </div>
      <div className="text-sm text-faint mt-1">{variable.description}</div>
    </div>
  )
}

export default RegionStringField
