import RouteContainer from "@/components/RouteContainer"
import SectionHeader from "@/components/SectionHeader"
import PublishModule from "@/components/modules/PublishModule"
import Loading from "@/navigation/Loading"
import { alertStore, userStore } from "@/store"
import { classNames } from "@/utils/dom"
import { envOrFail } from "@/utils/env"
import { modulesHasZeroData } from "@/utils/terraform"
import { ALERT_TYPE, IModule, IVariables } from "@/utils/types"
import { fetchAdminSettings } from "@/utils/variables"
import { ArrowLeftIcon } from "@heroicons/react/outline"
import axios from "axios"
import { useTranslation } from "next-i18next"
import { useEffect, useState } from "react"
import { useNavigate } from "react-router-dom"

enum PUBLISH_BUTTON {
  PUBLISH,
  UPDATE,
}

interface IPublishProps {}

type IPUBLISH_MODULE = {
  push: Function
}

const GCP_PROJECT_ID = envOrFail(
  "NEXT_PUBLIC_GCP_PROJECT_ID",
  process.env.NEXT_PUBLIC_GCP_PROJECT_ID,
)

const Publish: React.FC<IPublishProps> = ({}) => {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [publish, setPublish] = useState(true)
  const [checkButtonStatus, setButtonStatus] = useState<PUBLISH_BUTTON>(
    PUBLISH_BUTTON.PUBLISH,
  )
  const [arrayModules, setArrayModules] = useState<string[]>([])
  const buttonState = publish ? "disabled" : "primary"
  const [listAvaialableModules, setListAvaialableModules] = useState<IModule[]>(
    [],
  )
  const [isLoading, setLoading] = useState(true)
  const setAlert = alertStore((state) => state.setAlert)
  const user = userStore((state) => state.user)
  const [isSubmitLoading, setSubmitLoading] = useState(false)
  const [isUpdated, setIsUpdated] = useState(false)
  const [defaultSettingVarsData, setdefaultSettingVarsData] =
    useState<IVariables>({})
  const [publishedModulesData, setPublishedModulesData] = useState<IModule[]>(
    [],
  )
  const [hasGitModules, setGitModules] = useState(false)

  const goToPrevious = () => {
    navigate("/deployments")
  }

  const handleButtonClick = (state: boolean, name: string) => {
    //logic to keep selected modules in an array state so when we will publish,API will take array as a payload
    if (state) {
      setArrayModules((prevArray) => [...prevArray, name])
      setPublish(false)
    } else {
      const filterArray = arrayModules.filter((element) => {
        return element !== name
      })
      setArrayModules(filterArray)
      if (filterArray.length === 0) setPublish(true)
    }
  }

  const handlePublish = async () => {
    setSubmitLoading(true)
    // To check if selected module has group zero data
    const selectedModulesZeroGroup = await modulesHasZeroData(arrayModules)
    if (selectedModulesZeroGroup.length) {
      navigate("/modules/publish/provision", {
        state: {
          selectedModulesData: arrayModules,
          defaultSettingVarsData: defaultSettingVarsData,
          publishedModulesData: publishedModulesData,
        },
      })
    } else {
      // format payload modules as per API
      const formatPayloadArr: IPUBLISH_MODULE = []
      arrayModules.forEach((moduleName) => {
        let payloadFormat = {
          name: moduleName,
          publishedByEmail: user?.email,
          variables: {},
        }
        formatPayloadArr.push(payloadFormat)
      })
      const payload = {
        modules: formatPayloadArr,
      }
      //POST API with payload
      await axios
        .post(`/api/modules`, payload)
        .then((res) => {
          if (res.status === 200) {
            setAlert({
              message: t("module-success"),
              type: ALERT_TYPE.SUCCESS,
            })
          } else {
            setAlert({
              message: t("module-error"),
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
        })
    }
  }

  const handleUpdate = () => {
    //PUT API with payload = arrayModules
  }

  // get published module and set as selected
  const fetchPublishedModuleData = async () => {
    await axios
      .get(`/api/modules`)
      .then((res) => {
        setPublishedModulesData(res.data.modules)
        const formatModule: string[] = []
        res.data.modules?.forEach((module: IModule) => {
          let moduleName = module.name
          formatModule.push(moduleName)
        })
        setArrayModules(formatModule)
        if (formatModule.length) {
          setIsUpdated(true)
        }
      })
      .catch((error) => {
        console.error(error)
        setAlert({
          message: error.message,
          type: ALERT_TYPE.ERROR,
        })
      })
  }

  //Call the git api and assign the available modules
  const fetchAvaialableModuleData = async () => {
    setLoading(true)
    await axios
      .get(`/api/github/modules`)
      .then((res) => {
        setListAvaialableModules(res.data)
        if (res.data.length) {
          setGitModules(true)
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
        setLoading(false)
      })
  }

  // To check Admin settings updated if not thern redirect to default setting
  const fetchAdminSettingData = async () => {
    try {
      const settings = await fetchAdminSettings(GCP_PROJECT_ID)
      if (!settings) {
        navigate("/admin")
        return
      }
      setdefaultSettingVarsData(settings.variables)
    } catch (error) {
      console.error(error)
    }
  }

  const renderAllModules = () => {
    return listAvaialableModules
      .sort((a, b) => a.name.localeCompare(b.name))
      .map((module) => (
        <PublishModule
          title={module.name}
          key={module.name}
          defaultSelectedModules={arrayModules}
          handleButtonClick={handleButtonClick}
        />
      ))
  }

  useEffect(() => {
    fetchAdminSettingData()
    fetchAvaialableModuleData()
    fetchPublishedModuleData()
    // we can fetch API and check length of module names and according to, we can set update.
    var length: number = 0
    if (length >= 1) {
      setButtonStatus(PUBLISH_BUTTON.UPDATE)
    } else {
      setButtonStatus(PUBLISH_BUTTON.PUBLISH)
    }
  }, [])

  if (isLoading)
    return (
      <RouteContainer>
        <Loading />
      </RouteContainer>
    )

  return (
    <RouteContainer>
      {hasGitModules ? (
        <>
          <SectionHeader title={t("select-module")} />
          <div className="card bg-base-100 border-2 border-base-300 overflow-visible card-actions ">
            <div className="w-full text-left">
              <button
                className="btn btn-link hover:no-underline gap-1"
                onClick={goToPrevious}
                arial-label="back-button"
                data-testid="back-button"
              >
                <ArrowLeftIcon className="h-5 w-5" />
                {t("back")}
              </button>
            </div>
            <div className="card-body w-full text-left">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-x-8 gap-y-10">
                {renderAllModules()}
              </div>
              <div className="flex flex-row justify-center">
                {checkButtonStatus === PUBLISH_BUTTON.PUBLISH && (
                  <button
                    className="btn mt-10 btn-primary"
                    aria-label="publish-button"
                    data-testid="publish-button"
                    disabled={arrayModules.length === 0 || isSubmitLoading}
                    onClick={handlePublish}
                  >
                    {isSubmitLoading
                      ? t("loading")
                      : isUpdated
                      ? t("update")
                      : t("publish")}
                  </button>
                )}
                {checkButtonStatus === PUBLISH_BUTTON.UPDATE && (
                  <button
                    className={classNames("btn mt-10", `btn-${buttonState}`)}
                    aria-label="update-button"
                    data-testid="update-button"
                    disabled={buttonState !== "primary"}
                    onClick={handleUpdate}
                  >
                    {t("update")}
                  </button>
                )}
              </div>
            </div>
          </div>
        </>
      ) : (
        <div className="mt-10 text-center text-sm text-dim">
          {t("no-modules-message")}
        </div>
      )}
    </RouteContainer>
  )
}

export default Publish
