import { DEPLOYMENT_STATUS, TFStatus } from "@/utils/types"
import axios from "axios"
import { useTranslation } from "next-i18next"
import { useEffect, useState } from "react"
import { alertStore } from "@/store"
import { ALERT_TYPE } from "@/utils/types"
import { IDeployment, IModuleCard } from "@/utils/types"
import startCase from "lodash/startCase"
import {
  localDateFromSeconds,
  textColorFromDeployStatus,
} from "@/utils/deployments"
import ModuleOverviewCard from "@/components/modules/ModuleOverviewCard"
import ProjectLink from "../ProjectLink"

interface IModuleOverview {
  deployment: IDeployment
}

const ModuleOverview: React.FC<IModuleOverview> = ({ deployment }) => {
  const { t } = useTranslation()

  const [status, setStatus] = useState(
    deployment.status || DEPLOYMENT_STATUS.STATUS_UNKNOWN,
  )
  const [statusColor, setStatusColor] = useState(
    textColorFromDeployStatus(status),
  )
  const setAlert = alertStore((state) => state.setAlert)

  const CARDS: IModuleCard[] = [
    {
      title: t("module-name"),
      body: <>{startCase(deployment.module)}</>,
    },
    {
      title: t("gcp-link"),
      body: <ProjectLink deployment={deployment} />,
    },
    {
      title: t("status"),
      body: deployment.deletedAt ? (
        <span className="text-md text-error text-dim font-semibold uppercase">
          {t("deleted")}
        </span>
      ) : (
        <span className={`text-md text-${statusColor} font-semibold`}>
          {status}
        </span>
      ),
    },
    {
      title: t("user-email"),
      body: <>{deployment.deployedByEmail}</>,
    },
    {
      title: t("created-at"),
      body: <>{localDateFromSeconds(deployment.createdAt._seconds)}</>,
    },
    {
      title: t("updated-at"),
      body: deployment.updatedAt ? (
        <>{localDateFromSeconds(deployment.updatedAt._seconds)}</>
      ) : (
        <>-</>
      ),
    },
  ]

  const fetchData = async () => {
    try {
      const statusCheck = await axios.get(
        `/api/deployments/${deployment.deploymentId}/status`,
      )
      const { buildStatus } = TFStatus.parse(statusCheck.data)
      setStatus(buildStatus)
    } catch (error) {
      console.error(error)
      const errorStatus: any = error
      if (errorStatus.response.status !== 404) {
        setAlert({
          message: t("error"),
          durationMs: 10000,
          type: ALERT_TYPE.ERROR,
        })
      }
    }
  }

  useEffect(() => {
    fetchData()
  }, [])

  useEffect(() => {
    setStatusColor(textColorFromDeployStatus(status))
  }, [status])

  return (
    <div className="bg-base-300 mx-auto px-8 py-8 text-lg font-normal rounded-lg mt-2">
      {t("overview")}
      <div className="mt-2 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-x-4 gap-y-6">
        {CARDS.map((card) => (
          <ModuleOverviewCard key={card.title} card={card} />
        ))}
      </div>
    </div>
  )
}

export default ModuleOverview
