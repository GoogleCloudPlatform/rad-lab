import DefaultStepCreator from "@/components/forms/DefaultStepCreator"
import { FormikStepper } from "@/components/forms/FormikStepper"
import { alertStore, userStore } from "@/store"
import { groupVariables, initialFormikData } from "@/utils/terraform"
import {
  ALERT_TYPE,
  Dictionary,
  IFormData,
  ISecretManagerReq,
  IUIVariable,
  IVariables,
} from "@/utils/types"
import { mergeAllSafe } from "@/utils/variables"
import axios from "axios"
import { FormikValues } from "formik"
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
  const [answerValueData, setAnswerValueData] = useState<FormikValues>({})

  const handleSubmit = async (values: IFormData) => {
    handleLoading(true)

    if (values.email_notifications) {
      const secretManagerPayload: ISecretManagerReq = {
        key: "mailBoxCred",
        value: values.mail_server_password,
      }
      await saveMailBoxCred(secretManagerPayload)
    }

    delete values.mail_server_password
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

  const saveMailBoxCred = async (payload: ISecretManagerReq) => {
    try {
      await axios.post("/api/secret", payload)
    } catch (error: any) {
      setAlert({
        message: error.message,
        type: ALERT_TYPE.ERROR,
      })
    }
  }

  const handleChangeValues = (answerValues: FormikValues) => {
    setAnswerValueData(answerValues)
  }

  const formatDependsVariables = (
    formVariablesData: IUIVariable[],
    currentAnswerValueData: FormikValues,
  ) => {
    const allNonDependsVars = formVariablesData.filter(
      (formVariableData) =>
        formVariableData.name !== "mail_server_email" &&
        formVariableData.name !== "mail_server_password",
    )
    const allDependsVars = formVariablesData.filter(
      (formVariableData) =>
        formVariableData.name === "mail_server_email" ||
        formVariableData.name === "mail_server_password",
    )

    const notificationAnswer = currentAnswerValueData.email_notifications
    const releventParse = allNonDependsVars.concat(
      notificationAnswer ? allDependsVars : [],
    )
    return releventParse
  }

  useEffect(() => {
    if (formVariables.length > 0) {
      const initialFormVariable = setDefaultSettingVariables()
      setInitialData(initialFormVariable)
      const releventParse = formatDependsVariables(
        formVariables,
        answerValueData,
      )
      const groupedVariableList = groupVariables(releventParse)
      setFormData(groupedVariableList)
    }
  }, [formVariables, answerValueData])

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
                handleChangeValues={handleChangeValues}
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
