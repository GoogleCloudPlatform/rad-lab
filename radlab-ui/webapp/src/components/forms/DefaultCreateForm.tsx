import DefaultStepCreator from "@/components/forms/DefaultStepCreator"
import { FormikStepper } from "@/components/forms/FormikStepper"
import { alertStore, userStore } from "@/store"
import { groupVariables, initialFormikData } from "@/utils/terraform"
import {
  ALERT_TYPE,
  Dictionary,
  IFormData,
  IUIVariable,
  IVariables,
} from "@/utils/types"
import { mergeAllSafe } from "@/utils/variables"
import axios from "axios"
import { useTranslation } from "next-i18next"
import React, { useEffect, useState } from "react"
import { useNavigate } from "react-router-dom"

interface IDefaultCreateFormProps {
  formVariables: IUIVariable[]
  defaultSettingVariables: IVariables
  handleLoading: Function
}

const DefaultCreateForm: React.FC<IDefaultCreateFormProps> = ({
  formVariables,
  defaultSettingVariables,
  handleLoading,
}) => {
  const { t } = useTranslation()
  const [formData, setFormData] = useState<null | Dictionary<IUIVariable[]>>(
    null,
  )
  const [initialFormData, setInitialData] = useState({})
  const setAlert = alertStore((state) => state.setAlert)
  const user = userStore((state) => state.user)
  const navigate = useNavigate()

  const handleSubmit = async (values: IFormData) => {
    handleLoading(true)
    const payload = Object.assign(values, {
      email: user?.email,
    })
    await axios
      .post(`/api/settings`, payload)
      .then((res) => {
        if (res.status === 200) {
          setAlert({
            message: t("settings-success"),
            type: ALERT_TYPE.SUCCESS,
            durationMs: 10000,
          })
          navigate("/modules")
        } else {
          setAlert({
            message: t("settings-error"),
            type: ALERT_TYPE.ERROR,
          })
        }
      })
      .catch((error) => {
        console.error(error)
        setAlert({
          message: error.message,
          type: ALERT_TYPE.ERROR,
        })
      })
      .finally(() => {
        handleLoading(false)
      })
  }

  // To set matching deafult setting variables as default
  const setDefaultSettingVariables = () => {
    const initialFormData = initialFormikData(formVariables)
    return mergeAllSafe([initialFormData, defaultSettingVariables])
  }

  useEffect(() => {
    if (formVariables.length > 0) {
      const initialFormVariable = setDefaultSettingVariables()
      setInitialData(initialFormVariable)
      const groupedVariableList = groupVariables(formVariables)
      setFormData(groupedVariableList)
    }
  }, formVariables)

  return (
    <div className="w-full">
      {formData && (
        <FormikStepper
          initialValues={initialFormData}
          onSubmit={async (values) => handleSubmit(values)}
        >
          {Object.keys(formData).map((grpId, index) => {
            const group: undefined | IUIVariable[] = formData[grpId]
            return group ? (
              <DefaultStepCreator
                variableList={group}
                idx={index}
                key={grpId}
              />
            ) : (
              <></>
            )
          })}
        </FormikStepper>
      )}
    </div>
  )
}

export default DefaultCreateForm
