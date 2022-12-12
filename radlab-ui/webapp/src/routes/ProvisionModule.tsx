import React, { useState, useEffect } from "react"
import { useLocation, useNavigate } from "react-router-dom"
import { ArrowLeftIcon } from "@heroicons/react/outline"
import startCase from "lodash/startCase"

import RouteContainer from "@/components/RouteContainer"
import CreateForm from "@/components/forms/CreateForm"

import { parseVarsFile } from "@/utils/terraform"
import { useTranslation } from "next-i18next"
import axios from "axios"
import Loading from "@/navigation/Loading"
import { IUIVariable, ALERT_TYPE } from "@/utils/types"
import { alertStore } from "@/store"
import LoadingRow from "@/components/LoadingRow"

interface provisionMouduleInterface {}
type LocationState = {
  moduleName: string
}

const ProvisionModule: React.FC<provisionMouduleInterface> = ({}) => {
  const { state } = useLocation()
  const navigate = useNavigate()
  const { t } = useTranslation()
  const [navigationData, setNavigationData] = useState(false)
  const [moduleParseData, setModuleParseData] = useState<IUIVariable[]>([])
  const [isLoading, setLoading] = useState(true)
  const setAlert = alertStore((state) => state.setAlert)
  const [submitLoading, setSubmitLoading] = useState(false)

  const handleBackClick = () => {
    navigate(-1)
  }

  let selectedModuleName = ""

  if (navigationData) {
    const { moduleName } = state as LocationState
    selectedModuleName = moduleName
  }

  const fetchModuleFormData = async () => {
    const apiUrl = `/api/github/${selectedModuleName}/variables`

    await axios
      .get(apiUrl)
      .then((response) => {
        let decodeToString = Buffer.from(
          response.data.variables.content,
          "base64",
        ).toString()
        const parseData = parseVarsFile(decodeToString)
        const filterParseData = parseData.filter(
          (vars) => vars.name !== "deployment_id",
        )
        setModuleParseData(filterParseData)
      })
      .catch((error) => {
        console.error(error)
        setAlert({
          message: error.message,
          durationMs: 20000,
          type: ALERT_TYPE.ERROR,
        })
      })
    setLoading(false)
  }

  useEffect(() => {
    if (!state) {
      navigate("/deploy")
    } else {
      setNavigationData(true)
      if (selectedModuleName) {
        fetchModuleFormData()
      }
    }
  }, [selectedModuleName])

  if (isLoading)
    return (
      <RouteContainer>
        <Loading />
      </RouteContainer>
    )

  return (
    <RouteContainer>
      {navigationData && selectedModuleName && (
        <div className="card bg-base-100 border border-base-300 rounded-lg p-2 sm:min-h-full">
          <div className="w-full flex mb-6">
            <button
              className="btn btn-link gap-2 hover:no-underline"
              onClick={handleBackClick}
            >
              <ArrowLeftIcon className="h-5 w-5" />
              {t("cancel")}
            </button>
          </div>
          <div className="justify-center w-full mb-8">
            <div className="flex-row w-full text-center text-xl font-bold mb-4">
              {startCase(selectedModuleName)}
            </div>
            {submitLoading && <LoadingRow title={t("submit-deployment")} />}
            <div className="flex w-full px-4 sm:px-8 md:w-3/4 lg:w-1/2 mx-auto">
              <CreateForm
                formVariables={moduleParseData}
                selectedModuleName={selectedModuleName}
                update={false}
                handleLoading={setSubmitLoading}
              />
            </div>
          </div>
        </div>
      )}
    </RouteContainer>
  )
}

export default ProvisionModule
