import Loading from "@/navigation/Loading"
import { ILogHeader, URL, URLData, IBuildStep } from "@/utils/types"
import axios from "axios"
import { useEffect, useState } from "react"

import { textColorFromDeployStatus } from "@/utils/deployments"
import { userStore } from "@/store"
import { classNames } from "@/utils/dom"
import { EXAMPLE_CLOUD_BUILD_LOGS } from "@/utils/data"

interface IModuleLogs {
  deploymentId: string
  tableHeaders: ILogHeader[]
}

const ModuleLogs: React.FC<IModuleLogs> = ({ deploymentId }) => {
  const [loading, setLoading] = useState(true)
  const [buildSteps, setBuildSteps] = useState<IBuildStep[] | null>(null)
  const { isAdmin } = userStore((state) => state)

  const fetchData = () => {
    if (process.env.NEXT_PUBLIC_DEBUG_BUILD_LOGS) {
      return Promise.resolve(EXAMPLE_CLOUD_BUILD_LOGS).then((logs) =>
        logs.split("\n"),
      )
    }

    return axios
      .get(`/api/deployments/${deploymentId}/logs`)
      .then((res) => {
        const urlPath = URL.parse(res.data)
        return axios.get(urlPath.url)
      })
      .then((res) => {
        const urlData = URLData.parse(res)
        const lines: string[] = urlData.data.split("\n")
        return lines || []
      })
      .catch((error) => {
        console.error(error)
        return []
      })
  }

  const fetchBuildStatus = async () => {
    try {
      const statusCheck = await axios.get(
        `/api/deployments/${deploymentId}/status`,
      )
      const { buildSteps } = statusCheck.data
      const linesData = isAdmin ? await fetchData() : []

      const logStepDetails = buildSteps.map((step: IBuildStep, i: number) => {
        let filterVar = `Step #${i}`
        const logResult = linesData?.filter((line) => {
          return line.includes(filterVar)
        })
        return { ...step, logsContent: logResult }
      })

      setBuildSteps(logStepDetails)
      setLoading(false)
    } catch (error) {
      console.error(error)
    }
  }

  useEffect(() => {
    fetchBuildStatus()
  }, [])

  if (loading) return <Loading />

  return (
    <div className="w-full card card-actions bg-base-100 rounded-sm max-h-full">
      {buildSteps?.map((step: IBuildStep, i) => (
        <div
          key={step.id}
          tabIndex={i + 1}
          className={classNames(
            "border border-base-300 bg-base-100 rounded-box w-full",
            isAdmin
              ? "collapse collapse-arrow"
              : "cursor-not-allowed pointer-events-none",
          )}
        >
          <div className="collapse-title text-sm text-dim font-medium flex justify-between items-center">
            <span>{step.id}</span>
            <span
              className={`text-${textColorFromDeployStatus(
                step.status,
              )} font-semibold ml-1`}
            >
              {step.status}
            </span>
          </div>
          <div className="collapse-content">
            <div className="max-h-80 overflow-auto">
              {isAdmin && (
                <div className=" w-full border-2 border-base-300 rounded-lg block">
                  {step.logsContent?.map((line, i) => (
                    <div
                      key={line + i}
                      className={classNames(
                        "p-2 text-xs font-semibold text-faint break-words",
                        i % 2 === 0 ? "bg-base-100" : "bg-base-200",
                      )}
                    >
                      {line}
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      ))}
    </div>
  )
}

export default ModuleLogs
