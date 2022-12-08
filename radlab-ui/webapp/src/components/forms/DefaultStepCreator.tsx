import sortBy from "lodash/sortBy"
import { useFormikContext, FormikValues } from "formik"
import { FormikStep } from "@/components/forms/FormikStepper"

import { IUIVariable } from "@/utils/types"
import { useState, useEffect } from "react"

import StringField from "@/components/forms/fields/StringField"
import RegionStringField from "@/components/forms/fields/RegionStringField"
import ZoneStringField from "@/components/forms/fields/ZoneStringField"

import { ZONE_LIST } from "@/utils/data"

interface IDefaultStepCreatorProps {
  variableList: IUIVariable[]
  idx: number
}

type IFieldValidateValue = { value: string | number | boolean }

const DefaultStepCreator: React.FC<IDefaultStepCreatorProps> = ({
  variableList,
  idx,
}) => {
  const [zoneListData, setZoneListData] = useState<string[]>([])
  const { values } = useFormikContext<FormikValues>()

  let sortedList = sortBy(variableList, "order")

  const validateRequired = (value: IFieldValidateValue) => {
    let error
    if (!value) {
      error = "Required"
    }
    return error
  }

  const getZoneByRegion = (regionName: string) => {
    const zoneFilterData = ZONE_LIST.filter((v) => {
      const toMatchData = v.split("-")
      toMatchData.pop()
      const checkMatch = toMatchData.join("-")
      if (checkMatch === regionName) {
        return v
      } else {
        return ""
      }
    })
    return zoneFilterData
  }

  const onChangeRegion = (event: React.ChangeEvent<HTMLInputElement>) => {
    values[event.target.name] = event.target.value
    const zoneByRegion = getZoneByRegion(event.target.value)
    setZoneListData(zoneByRegion)

    // set first value as default zone while region changed
    values["zone"] = zoneByRegion[0]
  }

  const renderControls = (variable: IUIVariable) => {
    if (variable.name === "region") {
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
          zoneListByRegion={zoneListData}
        />
      )
    } else {
      return <StringField variable={variable} validate={validateRequired} />
    }
  }

  useEffect(() => {
    // To dispaly default list of zone based on region
    const zoneByRegion = getZoneByRegion(values.region)
    setZoneListData(zoneByRegion)
    // set first value as default zone while load
    if (!zoneByRegion.includes(values["zone"])) {
      values["zone"] = zoneByRegion[0]
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
