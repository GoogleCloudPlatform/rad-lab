import { Field, ErrorMessage } from "formik"
import { IUIVariable } from "@/utils/types"
import { useEffect, useState } from "react"
import { cloudLocationStore } from "@/store"

interface IZoneStringFieldProps {
  variable: IUIVariable
  validate: Function
  region?: string
}

const ZoneStringField: React.FC<IZoneStringFieldProps> = ({
  variable,
  validate,
  region,
}) => {
  const [zones, setZones] = useState<string[]>([])
  const cloudLocation = cloudLocationStore((state) => state.cloudLocation)

  useEffect(() => {
    ;(region ? cloudLocation.zonesByRegion(region) : cloudLocation.zones).then(
      (z) => {
        setZones(["", ...z])
      },
    )
  }, [region])

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
        {zones.map((zone) => {
          return (
            <option key={zone} value={zone}>
              {zone}
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

export default ZoneStringField
