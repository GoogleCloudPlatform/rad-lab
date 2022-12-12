import React, { useState, useEffect } from "react"
import { FormikStepper } from "@/components/forms/FormikStepper"
import StepCreator from "@/components/forms/StepCreator"
import {
  IUIVariable,
  Deployment,
  DEPLOYMENT_STATUS,
  IFormData,
} from "@/utils/types"
import {
  groupVariables,
  initialFormikData,
  getAdminSettingData,
  getPublishedDataByModuleName,
  defaultVariableData,
} from "@/utils/terraform"
import axios from "axios"
import { useNavigate, useParams } from "react-router-dom"
import { alertStore, userStore } from "@/store"
import { ALERT_TYPE, Dictionary } from "@/utils/types"
import { useTranslation } from "next-i18next"
import Loading from "@/navigation/Loading"
import UpdateSafeDeploymentModal from "@/components/UpdateSafeDeploymentModal"
import { whereEq } from "ramda"

interface CreateForm {
  formVariables: IUIVariable[]
  selectedModuleName: string
  update: boolean
  handleLoading: Function
}

const CreateForm: React.FC<CreateForm> = ({
  formVariables,
  selectedModuleName,
  update,
  handleLoading,
}) => {
  const { t } = useTranslation()
  const [formData, setFormData] = useState<null | Dictionary<IUIVariable[]>>(
    null,
  )
  const [initialFormData, setInitialData] = useState<Record<string, any>>({})
  const navigate = useNavigate()
  const setAlert = alertStore((state) => state.setAlert)
  const user = userStore((state) => state.user)
  const params = useParams()
  const [loading, setLoading] = useState(true)
  const [modalUpdateSafe, setUpdateSafeModal] = useState(false)
  const [modalUpdateSafePayload, setUpdateSafePayload] = useState({})

  if (!user) throw new Error("No signed in user")

  const removeAdminData = (datam: IFormData) => {
    const filterData: IFormData = []
    Object.keys(datam).forEach((value) => {
      const dataSelected = datam[value]
      /* not consider admin user related variable data which group has value 0 */
      if (dataSelected[0].group !== 0) {
        filterData.push(dataSelected)
      }
    })

    return filterData
  }

  /**
   * Represents the formik field default value
   * @ initialFormData
   * @param {string}  data - filtered data @removeAdminData
   */

  const initialFormikDefaultData = async (data: IFormData) => {
    const defaultVars = defaultVariableData(data)
    const adminVars = await getAdminSettingData()
    const moduleVars = await getPublishedDataByModuleName(selectedModuleName)
    if (update) {
      await axios
        .get(`/api/deployments/${params.deployId}`)
        .then((res) => {
          const deployment = Deployment.parse(res.data.deployment)
          const userVars = deployment.variables
          const variables = Object.assign(
            {},
            defaultVars,
            adminVars,
            moduleVars,
            userVars,
          )
          setInitialData(variables)
        })
        .catch((error) => {
          console.error(error)
        })
        .finally(() => setLoading(false))
    } else {
      const variables = Object.assign({}, defaultVars, adminVars, moduleVars)
      setInitialData(variables)
      setLoading(false)
    }
  }

  // To implement updateSafe data
  const updateSafeInitialFilterData = formVariables.filter(
    (v) => !v.updateSafe && v.group !== 0,
  )
  const updateSafeInitialData = initialFormikData(updateSafeInitialFilterData)

  const updateSafeInitialDataFinal = Object.keys(updateSafeInitialData).reduce(
    (updateSafeObject: Record<string, any>, objectKey) => {
      updateSafeObject[objectKey] = initialFormData[objectKey]
      return updateSafeObject
    },
    {},
  )

  const renderUpdateSafeModal = () => {
    if (!params.deployId) {
      throw new Error("Deployment ID is not set")
    } else {
      return (
        <UpdateSafeDeploymentModal
          deployId={params.deployId}
          safeUpdatePayload={modalUpdateSafePayload}
          safeUpdateData={updateSafeInitialData}
        />
      )
    }
  }

  const handleSubmit = async (values: IFormData) => {
    handleLoading(true)
    const payload = {
      module: selectedModuleName,
      deployedByEmail: user.email,
      variables: values,
      status: DEPLOYMENT_STATUS.QUEUED,
    }

    // TODO: check non update safe field are changed
    const checkUpdateSafeEqual = whereEq(updateSafeInitialDataFinal)
    const checkUpdateSafeChanged = checkUpdateSafeEqual(values)
    if (update && !checkUpdateSafeChanged) {
      setUpdateSafePayload(payload)
      setUpdateSafeModal(true)
    } else {
      const request = update
        ? axios.put(`/api/deployments/${params.deployId}`, payload)
        : axios.post(`/api/deployments`, payload)

      const successMsg = update ? t("update-success") : t("deploy-success")
      const errorMsg = update ? t("update-error") : t("deploy-error")

      request
        .then((res) => {
          if (res.status === 200) {
            const responseDeploymentId = update
              ? params.deployId
              : res.data.response.deploymentId
            setAlert({
              message: `${successMsg} - ${responseDeploymentId}`,
              durationMs: 10000,
              type: ALERT_TYPE.SUCCESS,
            })
            navigate("/deployments")
          } else {
            setAlert({
              message: errorMsg,
              type: ALERT_TYPE.ERROR,
            })
          }
        })
        .catch((error) => {
          console.error(error)
        })
        .finally(() => {
          handleLoading(false)
        })
    }
  }

  useEffect(() => {
    if (formVariables.length > 0) {
      const groupedVariableList = groupVariables(formVariables)
      const groupedVariableListFilter = removeAdminData(groupedVariableList)
      setFormData(groupedVariableListFilter)
      initialFormikDefaultData(groupedVariableListFilter)
    }
  }, formVariables)

  if (loading) return <Loading />

  return (
    <>
      <div className="w-full">
        {formData && initialFormData && (
          <FormikStepper
            initialValues={initialFormData}
            onSubmit={(values) => handleSubmit(values)}
          >
            {Object.keys(formData).map((grpId, index) => {
              const group: undefined | IUIVariable[] = formData[grpId]
              return group ? (
                <StepCreator variableList={group} idx={index} key={index} />
              ) : (
                <></>
              )
            })}
          </FormikStepper>
        )}
      </div>
      {modalUpdateSafe ? renderUpdateSafeModal() : null}
    </>
  )
}

export default CreateForm
