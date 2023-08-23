import { Field, ErrorMessage, useField } from "formik"
import { IUIVariable } from "@/utils/types"
import { useEffect, useState } from "react"
import { cloudLocationStore } from "@/store"

interface IZoneStringFieldProps {
  variable: IUIVariable
  validate: Function
  userZones?: string[]
}

const DEFAULT_ZONE = "us-central1-a"

const ZoneStringField: React.FC<IZoneStringFieldProps> = ({
  variable,
  validate,
  userZones,
}) => {
  const [zones, setZones] = useState<string[]>([])
  const [_, fieldMeta] = useField(variable.name)
  const cloudLocation = cloudLocationStore((state) => state.cloudLocation)

  useEffect(() => {
    if (userZones?.length) {
      setZones(userZones)
      return
    }
    const defaultZone = (fieldMeta.value ??
      variable.default ??
      DEFAULT_ZONE) as string
    const defaultRegion = defaultZone.replace(/-[a-z]$/, "")

    cloudLocation.zonesByRegion(defaultRegion).then(setZones)
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
