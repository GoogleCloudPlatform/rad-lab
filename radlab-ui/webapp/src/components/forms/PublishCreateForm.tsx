import StepCreator from "@/components/forms/StepCreator"
import { alertStore } from "@/store"
import { classNames } from "@/utils/dom"
import { initialFormikData } from "@/utils/terraform"
import {
  ALERT_TYPE,
  IFormData,
  IModuleFormData,
  IPayloadPublishData,
  IUIVariable,
} from "@/utils/types"
import { mergeAllSafe } from "@/utils/variables"
import axios from "axios"
import { Form, Formik } from "formik"
import startCase from "lodash/startCase"
import { useTranslation } from "next-i18next"
import React, { useEffect, useState } from "react"
import { useNavigate } from "react-router-dom"

interface IPublishCreateFormProps {
  formVariables: IModuleFormData[]
  payloadVariables: IPayloadPublishData[]
  defaultSettingVariables: Record<string, any>
  handleLoading: Function
}

const PublishCreateForm: React.FC<IPublishCreateFormProps> = ({
  formVariables,
  payloadVariables,
  defaultSettingVariables,
  handleLoading,
}) => {
  const { t } = useTranslation()
  const [formData, setFormData] = useState<IFormData>([])
  const [initialFormData, setInitialData] = useState({})
  const setAlert = alertStore((state) => state.setAlert)
  const navigate = useNavigate()
  const [step, setStep] = useState(0)
  const [completed, setCompleted] = useState(false)
  const [isSubmitLoading, setSubmitLoading] = useState(false)
  const [isSubmit, setSubmit] = useState(false)

  const currentVarsData = formVariables[step]
  if (!currentVarsData) {
    throw new Error()
  }

  function isLastStep() {
    return step === Object.keys(formVariables).length - 1
  }

  const goBack = () => {
    setStep((s) => s - 1)
  }

  const onSubmit = async (values: IFormData, action: any) => {
    action.setSubmitting(false)
    window.scrollTo(0, 0)
    if (isLastStep()) {
      setCompleted(true)
    } else {
      if (!isSubmit) {
        setStep((s) => s + 1)
      }

      action.setTouched({})
      // uncomment in case not need previous data as default
      //action.resetForm()
    }
    captureSubmitData(values)
  }

  // to get all submit data into the API
  let captureSubmitFormat: IPayloadPublishData[] = payloadVariables
  const captureSubmitData = (formSubmitValues: IFormData) => {
    const currentModuleName = currentVarsData?.moduleName
    const index = captureSubmitFormat.findIndex(
      (item) => item.name === currentModuleName,
    )
    // set submit data to an array
    captureSubmitFormat[index]!.variables = formSubmitValues
    if (isSubmit) {
      submitDataAPI(captureSubmitFormat)
    }
  }

  const submitDataAPI = async (formatPayloadArr: IPayloadPublishData[]) => {
    handleLoading(true)
    setSubmitLoading(true)
    const payload = {
      modules: formatPayloadArr,
    }
    //POST publish API with payload
    await axios
      .post(`/api/modules`, payload)
      .then((res) => {
        if (res.status === 200) {
          setAlert({
            message: t("publish-success"),
            type: ALERT_TYPE.SUCCESS,
            durationMs: 10000,
          })
          navigate("/modules")
        } else {
          setAlert({
            message: t("publish-error"),
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
        setSubmitLoading(false)
        handleLoading(false)
      })
  }

  // To set matching deafult setting variables as default
  const setDefaultSettingVariables = () => {
    const initialFormVarData = initialFormikData(currentVarsData.variables)
    const indexPublishedModuleVars = payloadVariables.findIndex(
      (item) => item.name === currentVarsData.moduleName,
    )
    const updateFormData = payloadVariables[indexPublishedModuleVars]!.variables

    // Remove emptry strings as values so merging works
    return mergeAllSafe([
      defaultSettingVariables,
      initialFormVarData,
      updateFormData,
    ])
  }

  useEffect(() => {
    const initialFormVariable = setDefaultSettingVariables()
    setInitialData(initialFormVariable)
    setFormData([currentVarsData.variables])
  }, [currentVarsData.variables])

  return (
    <div className="w-full">
      {formData.length && initialFormData && (
        <>
          <ul className="steps w-full mb-4 text-sm">
            {Object.keys(formVariables).map((child: string, index) => (
              <li
                key={child}
                className={classNames(
                  "step cursor-pointer",
                  step + 1 > index || completed ? "step-primary" : "",
                )}
                onClick={() => setStep(() => index)}
              >
                {startCase(formVariables[index]?.moduleName)}
              </li>
            ))}
          </ul>
          <Formik
            enableReinitialize
            initialValues={initialFormData}
            onSubmit={async (values, action) => {
              await onSubmit(values, action)
            }}
            validateOnMount
          >
            {({ isSubmitting, isValid }) => (
              <Form autoComplete="off">
                {Object.keys(formData).map((grpId, index) => {
                  const group: undefined | IUIVariable[] = formData[grpId]
                  return group ? (
                    <StepCreator variableList={group} idx={index} key={grpId} />
                  ) : (
                    <></>
                  )
                })}
                <div className="flex-row justify-center gap-x-4">
                  {step > 0 ? (
                    <button
                      type="button"
                      className="btn btn-outline btn-primary w-32"
                      disabled={isSubmitting || isSubmitLoading}
                      onClick={goBack}
                    >
                      Previous
                    </button>
                  ) : null}
                  <button
                    type="submit"
                    className="btn btn-primary float-right w-32"
                    disabled={!isValid || isSubmitting || isSubmitLoading}
                    onClick={() => setSubmit(true)}
                  >
                    {isSubmitting || isSubmitLoading ? "Submitting" : "Submit"}
                  </button>
                  {!isLastStep() ? (
                    <button
                      type="submit"
                      className="btn btn-primary float-right w-32 sm:mr-2"
                      disabled={!isValid || isSubmitting || isSubmitLoading}
                    >
                      Next
                    </button>
                  ) : (
                    <></>
                  )}
                </div>
              </Form>
            )}
          </Formik>
        </>
      )}
    </div>
  )
}

export default PublishCreateForm
