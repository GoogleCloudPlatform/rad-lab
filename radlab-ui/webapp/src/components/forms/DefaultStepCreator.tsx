import sortBy from "lodash/sortBy"
import { useFormikContext, FormikValues } from "formik"
import { FormikStep } from "@/components/forms/FormikStepper"

import { IUIVariable, IRegion } from "@/utils/types"
import { useState, useEffect } from "react"

import StringField from "@/components/forms/fields/StringField"
import RegionStringField from "@/components/forms/fields/RegionStringField"
import ZoneStringField from "@/components/forms/fields/ZoneStringField"

interface IDefaultStepCreatorProps {
  variableList: IUIVariable[]
  idx: number
  regionZoneList: IRegion[]
}

type IFieldValidateValue = { value: string | number | boolean }

const alphabetically = (a: string, b: string) => a.localeCompare(b)

const DefaultStepCreator: React.FC<IDefaultStepCreatorProps> = ({
  variableList,
  idx,
  regionZoneList,
}) => {
  const [regionNames, setRegionNames] = useState<string[]>([])
  const [zoneNames, setZoneNames] = useState<string[]>([])
  const { values } = useFormikContext<FormikValues>()

  const sortedList = sortBy(variableList, "order")

  const validateRequired = (value: IFieldValidateValue) => {
    let error
    if (!value) {
      error = "Required"
    }
    return error
  }

  const fetchRegionList = () => {
    setRegionNames(
      regionZoneList.map((region) => region.name).sort(alphabetically),
    )
  }

  const getZonesByRegion = (regionName: string) => {
    const selectedRegion = regionZoneList.find(
      (region) => region.name === regionName,
    )
    const zoneFilterData = selectedRegion?.zones || []
    return zoneFilterData
  }

  const onChangeRegion = (event: React.ChangeEvent<HTMLInputElement>) => {
    values[event.target.name] = event.target.value
    const zones = getZonesByRegion(event.target.value)
    setZoneNames(zones.sort(alphabetically))

    // set first value as default zone while region changed
    values["zone"] = zones[0]
  }

  const renderControls = (variable: IUIVariable) => {
    if (variable.name === "region") {
      variable.options = regionNames
      return (
        <RegionStringField
          variable={variable}
          validateRequired={validateRequired}
          onChangeRegion={onChangeRegion}
        />
      )
    } else if (variable.name === "zone") {
      return (
        <ZoneStringField
          variable={variable}
          validateRequired={validateRequired}
          zoneListByRegion={zoneNames}
        />
      )
    } else {
      return <StringField variable={variable} validate={validateRequired} />
    }
  }

  useEffect(() => {
    fetchRegionList()
    // To dispaly default list of zone based on region
    const zones = getZonesByRegion(values.region)
    setZoneNames(zones.sort(alphabetically))
    // set first value as default zone while load
    if (!zones.includes(values["zone"])) {
      values["zone"] = zones[0]
    }
  }, [])

  return (
    <>
      <FormikStep label={(idx + 1).toFixed(0)}>
        <div className="grid grid-flow-row">
          {sortedList.map((elem) => (
            <div key={elem.name}>{renderControls(elem)}</div>
          ))}
        </div>
      </FormikStep>
    </>
  )
}

export default DefaultStepCreator
