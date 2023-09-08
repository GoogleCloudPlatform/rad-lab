import Loading from "@/navigation/Loading"
import { ILogHeader, URL, URLData, IBuildStep } from "@/utils/types"
import axios from "axios"
import { useEffect, useState } from "react"

import { textColorFromDeployStatus } from "@/utils/deployments"
import { userStore } from "@/store"
import { classNames } from "@/utils/dom"

interface IModuleLogs {
  deploymentId: string
  tableHeaders: ILogHeader[]
}

const ModuleLogs: React.FC<IModuleLogs> = ({ deploymentId }) => {
  const [loading, setLoading] = useState(true)
  const [buildSteps, setBuildSteps] = useState<IBuildStep[] | null>(null)
  const { isAdmin } = userStore((state) => state)

  const fetchData = async () => {
    return await axios
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

      const logStepDetails = buildSteps.map(
        (steps: IBuildStep, index: Number) => {
          let filterVar = `Step #${index}`
          const logResult = linesData?.filter((line) => {
            return line.includes(filterVar)
          })
          return { ...steps, logsContent: logResult }
        },
      )

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
          tabIndex={i}
          className={classNames(
            "border border-base-300 bg-base-100 rounded-box w-full",
            isAdmin
              ? "collapse collapse-arrow"
              : "cursor-not-allowed pointer-events-none bg-base-300",
          )}
        >
          <div className="collapse-title text-sm text-dim font-medium">
            {step.id}:
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
                <table className="table w-full divide-y divide-base-200 border-2 border-base-300 rounded-lg block">
                  <tbody className="bg-base-100 divide-y-2 divide-base-300 w-full">
                    {step.logsContent?.map((line, index) => (
                      <tr key={line + index}>
                        <td className="border border-base-300 px-1 py-2 text-xs font-semibold text-faint">
                          {line}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>
          </div>
        </div>
      ))}
    </div>
  )
}

export default ModuleLogs
