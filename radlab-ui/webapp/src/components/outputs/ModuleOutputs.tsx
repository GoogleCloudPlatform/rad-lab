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
  TF_OUTPUT_VARIABLE,
} from "@/utils/types"
import { useTranslation } from "next-i18next"
import { alertStore } from "@/store"

interface ModuleOutputsProps {
  deploymentId: string
  deployment: IDeployment
}

const isURL = (val: string) => val.search(/^https?:\/\//) > -1

const renderTFValue = (val: any): JSX.Element => {
  if (typeof val === "string" && isURL(val)) {
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

const renderTFValues = (val: TF_OUTPUT_VARIABLE | null): JSX.Element => {
  if (val === null || val.value === null) {
    return <></>
  }
  if (typeof val.value === "object" && !Array.isArray(val.value)) {
    return (
      <>
        {Object.entries(val.value).map(([objKey, objValue]) => (
          <div key={objKey}>
            {typeof objValue === "string" ? (
              <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3">
                <div className="text-left text-faint col-span-1">{objKey}</div>
                <div className="col-span-2 sm:col-span-1 break-words">
                  {renderTFValue(objValue)}
                </div>
              </div>
            ) : (
              <>{renderTFValues(objValue)}</>
            )}
          </div>
        ))}
      </>
    )
  }
  if (Array.isArray(val.value)) {
    return <>{val.value.map(renderTFValue)}</>
  }

  return renderTFValue(val.value)
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
    status === DEPLOYMENT_STATUS.SUCCESS && !deployment.deletedAt

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
    shouldShowOutputs() && fetchOutputs()
    fetchStatus()
  }, [deployment])

  if (!shouldShowOutputs()) return <LoadingRow title={t("output-progress")} />

  if (loading) return <Loading />

  if (error) return <div className="text-center text-error">{error}</div>

  return (
    <div className="bg-base-100 -mt-4">
      {Object.entries(outputs || {}).map(([variable, output]) => (
        <div
          className="grid grid-cols-3 sm:grid-cols-2 gap-x-3 sm:gap-x-6 mt-4 break-words"
          key={variable}
        >
          <div className="text-right text-faint col-span-1">{variable}</div>
          <div className="col-span-2 sm:col-span-1 break-words">
            {renderTFValues(output)}
          </div>
        </div>
      ))}
    </div>
  )
}

export default ModuleOutputs
