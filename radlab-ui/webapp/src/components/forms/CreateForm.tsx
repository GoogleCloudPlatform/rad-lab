import React, { useState, useEffect } from "react"
import { FormikStepper } from "@/components/forms/FormikStepper"
import StepCreator from "@/components/forms/StepCreator"
import { IUIVariable, Deployment, DEPLOYMENT_STATUS } from "@/utils/types"
import { groupVariables, initialFormikData } from "@/utils/terraform"
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
  data: string
  update: boolean
  handleLoading: Function
}
interface IFormatData {
  [key: string]: any
}
type IObjKeyPair = {
  [key: string]: string
}

const CreateForm: React.FC<CreateForm> = ({
  formVariables,
  data,
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

  const removeAdminData = (datam: IFormatData) => {
    const filterData: IFormatData = []
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

  const initialFormikDefaultData = async (data: IFormatData) => {
    if (update) {
      await axios
        .get(`/api/deployments/${params.deployId}`)
        .then((res) => {
          const deployment = Deployment.parse(res.data.deployment)
          setInitialData(deployment.variables)
        })
        .catch((error) => {
          console.error(error)
        })
        .finally(() => setLoading(false))
    } else {
      const initialObjData: IObjKeyPair = {}
      for (let i = 0; i < data.length; i++) {
        const element = data[i]
        for (let j = 0; j < element.length; j++) {
          const title = element[j].name
          let defaultValue = element[j].default
          let type = element[j].type
          if (
            defaultValue === null &&
            (type === "list(string)" ||
              type === "list(number)" ||
              type === "set(number)" ||
              type === "set(string)")
          ) {
            defaultValue = []
          } else if (defaultValue === null && type === "number") {
            defaultValue = 0
          } else if (defaultValue === null && type === "bool") {
            defaultValue = false
          } else if (defaultValue === null) {
            defaultValue = ""
          }
          initialObjData[title] = defaultValue
        }
        setLoading(false)
      }
      setInitialData(initialObjData)
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

  const handleSubmit = async (values: IFormatData) => {
    handleLoading(true)
    const payload = {
      module: data,
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
        {formData && (
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
