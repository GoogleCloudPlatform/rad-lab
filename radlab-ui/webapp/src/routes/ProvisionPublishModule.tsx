import React, { useState, useEffect } from "react"
import { useLocation, useNavigate } from "react-router-dom"
import { ArrowLeftIcon } from "@heroicons/react/outline"

import RouteContainer from "@/components/RouteContainer"
import PublishCreateForm from "@/components/forms/PublishCreateForm"

import { modulesHasZeroData } from "@/utils/terraform"

import { userStore } from "@/store"
import { IPayloadPublishData, IModuleFormData, IModule } from "@/utils/types"
import { classNames } from "@/utils/dom"
import { useTranslation } from "next-i18next"
import LoadingRow from "@/components/LoadingRow"
import Loading from "@/navigation/Loading"

interface IProvisionPublishMouduleProps {}
type LocationState = {
  selectedModulesData: string[]
  defaultSettingVarsData: {}
  publishedModulesData: IModule[]
}

const ProvisionPublishModule: React.FC<
  IProvisionPublishMouduleProps
> = ({}) => {
  const { state } = useLocation()
  const navigate = useNavigate()
  const { t } = useTranslation()

  const [navigationData, setNavigationData] = useState(false)
  const [moduleData, setModuleData] = useState<IModuleFormData[]>([])
  const user = userStore((state) => state.user)
  const [modulePayloadData, setPayloadModuleData] = useState<
    IPayloadPublishData[]
  >([])
  const [adminDefaultSettingVarsData, setAdminDefaultSettingVarsData] =
    useState({})
  const [submitLoading, setSubmitLoading] = useState(false)
  const [isLoading, setLoading] = useState(true)

  const handleBackClick = () => {
    navigate("/modules")
  }

  let selectedPublishModules: string[] = []
  let getDefaultSettingVarsData = {}
  let getPublishedModulesData: IModule[] = []
  if (navigationData) {
    const {
      selectedModulesData,
      defaultSettingVarsData,
      publishedModulesData,
    } = state as LocationState
    selectedPublishModules = selectedModulesData
    getDefaultSettingVarsData = defaultSettingVarsData
    getPublishedModulesData = publishedModulesData
  }
  // all selected module payload format
  const modulesPayloadDataFormat = async (arrayModules: string[]) => {
    const formatModulesPayload = await Promise.all(
      arrayModules
        .sort((a, b) => a.localeCompare(b))
        .map(async (moduleName: string) => {
          const publishedModule = getPublishedModulesData.find(
            (item) => item.name === moduleName,
          )

          return {
            name: moduleName,
            publishedByEmail: user?.email,
            variables: publishedModule?.variables ?? {},
          }
        }),
    )
    setPayloadModuleData(formatModulesPayload)
  }

  const modulesVarDataFormat = async (arrayModules: string[]) => {
    // only pass to form zero group varuiables modules
    const onlyZeroGroupModules = await modulesHasZeroData(
      arrayModules.sort((a, b) => a.localeCompare(b)),
    )
    setModuleData(onlyZeroGroupModules)

    onlyZeroGroupModules.length ? setLoading(false) : setLoading(true)
  }

  useEffect(() => {
    if (!state) {
      navigate("/modules")
    } else {
      setNavigationData(true)
    }
    if (selectedPublishModules) {
      modulesVarDataFormat(selectedPublishModules)
      modulesPayloadDataFormat(selectedPublishModules)
      setAdminDefaultSettingVarsData(getDefaultSettingVarsData)
    }
  }, [selectedPublishModules])

  if (isLoading)
    return (
      <RouteContainer>
        <Loading />
      </RouteContainer>
    )

  return (
    <RouteContainer>
      {navigationData && selectedPublishModules && moduleData.length && (
        <div className="card bg-base-100 border border-base-300 rounded-lg p-2 sm:min-h-full">
          <div className="w-full flex mb-6">
            <button className="btn btn-link gap-2" onClick={handleBackClick}>
              <ArrowLeftIcon className="h-5 w-5" />
              Cancel
            </button>
          </div>
          {submitLoading && <LoadingRow title={t("publish-module")} />}
          <div className="justify-center w-full mb-8">
            <div
              className={classNames(
                "flex w-full mx-auto",
                moduleData.length > 5 ? "sm:w-3/5" : "sm:w-2/5",
              )}
            >
              <PublishCreateForm
                formVariables={moduleData}
                payloadVariables={modulePayloadData}
                defaultSettingVariables={adminDefaultSettingVarsData}
                handleLoading={setSubmitLoading}
              />
            </div>
          </div>
        </div>
      )}
    </RouteContainer>
  )
}

export default ProvisionPublishModule
