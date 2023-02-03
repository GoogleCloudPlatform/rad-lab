import { useEffect, useState } from "react"
import axios from "axios"
import Loading from "@/navigation/Loading"
import LoadingRow from "@/components/LoadingRow"
import {
  ALERT_TYPE,
  DEPLOYMENT_STATUS,
  IDeployment,
  TFStatus,
  TF_OUTPUT,
} from "@/utils/types"
import { useTranslation } from "next-i18next"
import { alertStore } from "@/store"

interface ModuleOutputsProps {
  deploymentId: string
  deployment: IDeployment
}

const isURL = (val: string) => val.search(/^https?:\/\//) > -1

const renderTFValue = (val: string): JSX.Element => {
  if (isURL(val)) {
    return (
      <a
        className="block mb-2"
        key={val}
        href={val}
        target="_blank"
        rel="noopener"
      >
        {val}
      </a>
    )
  }
  return (
    <div key={val} className="mb-2">
      {val}
    </div>
  )
}

const renderTFValues = (val: any): JSX.Element => {
  if (Array.isArray(val)) {
    return <>{val.map(renderTFValue)}</>
  }

  return renderTFValue(val)
}

const ModuleOutputs: React.FC<ModuleOutputsProps> = ({
  deploymentId,
  deployment,
}) => {
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [outputs, setOutputs] = useState<TF_OUTPUT | null>(null)
  const { t } = useTranslation()
  const setAlert = alertStore((state) => state.setAlert)
  const [status, setStatus] = useState(
    deployment.status || DEPLOYMENT_STATUS.STATUS_UNKNOWN,
  )

  const shouldShowOutputs = () =>
    status !== DEPLOYMENT_STATUS.WORKING && !deployment.deletedAt

  const fetchOutputs = async () => {
    await axios
      .get(`/api/deployments/${deploymentId}/outputs`)
      .then((res) => {
        setOutputs(TF_OUTPUT.parse(res.data.outputs))
      })
      .catch((error) => {
        console.error(error)
        setError(
          "Failed to load Terraform outputs. Did the deploy complete successfully?",
        )
      })
      .finally(() => {
        setLoading(false)
      })
  }

  const fetchStatus = async () => {
    try {
      const statusCheck = await axios.get(
        `/api/deployments/${deploymentId}/status`,
      )
      const { buildStatus } = TFStatus.parse(statusCheck.data)
      setStatus(buildStatus)
    } catch (error) {
      setError("Failed to load Build Id. Did the deploy complete successfully?")
      console.error(error)
      setLoading(false)
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
    shouldShowOutputs() && fetchOutputs()
    fetchStatus()
  }, [deployment])

  if (loading) return <Loading />

  if (error) return <div className="text-center text-error">{error}</div>

  if (!shouldShowOutputs()) return <LoadingRow title={t("output-progress")} />

  return (
    <div className="bg-base-100 -mt-4">
      {Object.entries(outputs || {}).map(([variable, output]) => (
        <div
          className="grid grid-cols-3 sm:grid-cols-2 gap-x-3 sm:gap-x-6 mt-4 break-words"
          key={variable}
        >
          <div className="text-right text-faint col-span-1">{variable}</div>
          <div className="col-span-2 sm:col-span-1 break-words">
            {renderTFValues(output.value)}
          </div>
        </div>
      ))}
    </div>
  )
}

export default ModuleOutputs
