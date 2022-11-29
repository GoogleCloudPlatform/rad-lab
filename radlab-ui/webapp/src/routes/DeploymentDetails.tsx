import ModuleLogs from "@/components/logs/ModuleLogs"
import ModuleOverview from "@/components/modules/ModuleOverview"
import RouteContainer from "@/components/RouteContainer"
import { classNames } from "@/utils/dom"
import {
  AdjustmentsIcon,
  ArrowLeftIcon,
  RefreshIcon,
  TrashIcon,
} from "@heroicons/react/outline"
import { useTranslation } from "next-i18next"
import { useEffect, useState } from "react"
import { useLocation, useNavigate, useParams } from "react-router-dom"
import { BUILD_HEADER, LOGS_HEADERS } from "@/utils/data"
import DeleteDeploymentModal from "@/components/DeleteDeploymentModal"
import axios from "axios"
import { IDeployment, Deployment, DEPLOYMENT_STATUS } from "@/utils/types"
import { alertStore } from "@/store"
import { ALERT_TYPE } from "@/utils/types"
import ModuleOutputs from "@/components/outputs/ModuleOutputs"
import ModuleBuilds from "@/components/builds/ModuleBuilds"

enum TAB_DETAILS {
  OUTPUTS,
  LOG,
  BUILDS,
}

const validUpdateStatuses = [
  DEPLOYMENT_STATUS.SUCCESS,
  DEPLOYMENT_STATUS.FAILURE,
  DEPLOYMENT_STATUS.INTERNAL_ERROR,
  DEPLOYMENT_STATUS.TIMEOUT,
  DEPLOYMENT_STATUS.CANCELLED,
  DEPLOYMENT_STATUS.EXPIRE,
]

interface IDeploymentDetails {}

const DeploymentDetails: React.FC<IDeploymentDetails> = ({}) => {
  const navigate = useNavigate()
  const params = useParams()
  const { state } = useLocation()
  const { t } = useTranslation()

  const [deployment, setDeployment] = useState<IDeployment | null>(null)
  const [tabStatus, setTabStatus] = useState(TAB_DETAILS.BUILDS)
  const [modal, setModal] = useState(false)
  const setAlert = alertStore((state) => state.setAlert)
  const [deployInProgress, setDeployInProgress] = useState(false)
  const deployId = params.deployId
  const [isLoading, setLoading] = useState(false)

  if (!deployId) {
    throw new Error("Deployment ID is not set")
  }

  const handleClick = (state: boolean) => {
    setModal(state)
  }

  const renderModal = () => (
    <DeleteDeploymentModal deployId={deployId} handleClick={handleClick} />
  )

  const handleUpdate = () => {
    if (!deployment) throw new Error("Deployment not set")

    navigate(`update`, {
      state: { moduleName: deployment.module },
    })
  }

  const fetchDeployment = async () => {
    setLoading(true)
    try {
      const res = await axios.get(`/api/deployments/${deployId}`)
      const deploy = Deployment.parse(res.data.deployment)
      setDeployment(deploy)
      setDeployInProgress(isDeployInProgress(deploy.status))
    } catch (error) {
      console.error(error)
      setAlert({
        message: t("error"),
        durationMs: 10000,
        type: ALERT_TYPE.ERROR,
      })
    } finally {
      setLoading(false)
    }
  }

  const renderTabHeader = (
    tab: TAB_DETAILS,
    title: string,
    currentTab: TAB_DETAILS,
  ) => (
    <a
      className={classNames(
        "tab md:tab-lg lg:tab-lg",
        "mr-1 rounded-t-lg",
        currentTab === tab ? "bg-base-100" : "bg-base-300",
        currentTab === tab ? "tab-active" : "",
      )}
      onClick={() => setTabStatus(tab)}
    >
      {title}
    </a>
  )

  const isDeployInProgress = (deploymentStatus: DEPLOYMENT_STATUS) => {
    return [
      DEPLOYMENT_STATUS.QUEUED,
      DEPLOYMENT_STATUS.PENDING,
      DEPLOYMENT_STATUS.WORKING,
    ].includes(deploymentStatus)
  }

  useEffect(() => {
    // @ts-ignore
    if (state?.deployment) {
      // Already have deployment from previous page
      // @ts-ignore
      setDeployment(state.deployment)
      // @ts-ignore
      setDeployInProgress(isDeployInProgress(state.deployment.status))
    } else {
      fetchDeployment()
    }
  }, [])

  useEffect(() => {
    const t: TAB_DETAILS = !deployment
      ? TAB_DETAILS.BUILDS
      : deployment.deletedAt
      ? TAB_DETAILS.BUILDS
      : deployment.status === DEPLOYMENT_STATUS.SUCCESS
      ? TAB_DETAILS.OUTPUTS
      : TAB_DETAILS.LOG

    setTabStatus(t)
  }, [deployment])

  return (
    <RouteContainer>
      {deployment && (
        <>
          <div className="w-full flex flex-col sm:flex-row justify-between">
            <button
              className="btn btn-link gap-1 hover:no-underline transition"
              onClick={() => navigate("/deployments")}
            >
              <ArrowLeftIcon className="h-5 w-5" />
              {t("back")}
            </button>
            <div className="text-center mt-2">
              <button
                className="btn btn-link btn-sm gap-1 hover:no-underline transition hover:bg-base-300"
                onClick={fetchDeployment}
                disabled={isLoading}
              >
                <RefreshIcon
                  className={classNames(
                    "h-5 w-5",
                    isLoading ? "animate-spin" : "",
                  )}
                />
                {isLoading ? t("refreshing") : t("refresh")}
              </button>
              {!deployment.deletedAt && (
                <>
                  <span
                    className={classNames(
                      `${deployInProgress && "tooltip tooltip-primary"}`,
                    )}
                    data-tip={deployInProgress && t("status-progress-message")}
                  >
                    <button
                      className="btn btn-link btn-sm gap-1 ml-2 hover:no-underline transition hover:bg-base-300"
                      onClick={() => setModal(true)}
                      disabled={deployInProgress}
                    >
                      <TrashIcon className="h-5 w-5" />
                      {t("delete")}
                    </button>
                  </span>
                  <span
                    className={classNames(
                      `${deployInProgress && "tooltip tooltip-primary"}`,
                    )}
                    data-tip={deployInProgress && t("status-progress-message")}
                  >
                    <button
                      className="btn btn-link btn-sm gap-1 ml-2 hover:no-underline transition hover:bg-base-300 "
                      onClick={handleUpdate}
                      disabled={
                        !validUpdateStatuses.includes(deployment.status)
                      }
                    >
                      <AdjustmentsIcon className="h-5 w-5" />
                      {t("update")}
                    </button>
                  </span>
                </>
              )}
            </div>
          </div>
          <ModuleOverview deployment={deployment} />
          <div className="tabs mt-8 rounded-t-lg">
            {renderTabHeader(TAB_DETAILS.OUTPUTS, t("outputs"), tabStatus)}
            {renderTabHeader(TAB_DETAILS.LOG, t("logs"), tabStatus)}
            {renderTabHeader(TAB_DETAILS.BUILDS, t("builds"), tabStatus)}
          </div>
          <div className="p-8 bg-base-100 rounded-b-lg rounded-tr-lg shadow-lg">
            {!isLoading ? (
              <>
                {tabStatus === TAB_DETAILS.OUTPUTS && (
                  <ModuleOutputs
                    deploymentId={deployId}
                    deployment={deployment}
                  />
                )}
                {tabStatus === TAB_DETAILS.LOG && (
                  <ModuleLogs
                    deploymentId={deployId}
                    tableHeaders={LOGS_HEADERS}
                  />
                )}
                {tabStatus === TAB_DETAILS.BUILDS && (
                  <ModuleBuilds
                    deploymentId={deployId}
                    buildDataHeader={BUILD_HEADER}
                  />
                )}
              </>
            ) : (
              <p className="flex flex-col space-y-2 w-full text-center m-2 md:text-lg text-dim font-semibold">
                {t("refreshing")}
              </p>
            )}
          </div>
          {modal ? renderModal() : null}
        </>
      )}
    </RouteContainer>
  )
}

export default DeploymentDetails
