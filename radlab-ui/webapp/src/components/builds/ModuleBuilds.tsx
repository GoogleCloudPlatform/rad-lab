import Loading from "@/navigation/Loading"
import { localDateFromSeconds } from "@/utils/deployments"
import { Builds, Deployment, IBuild, IBuildHeader } from "@/utils/types"
import axios from "axios"
import { useTranslation } from "next-i18next"
import { useEffect, useState } from "react"

interface ModuleBuildsProps {
  deploymentId: string
  buildDataHeader: IBuildHeader[]
}

const ModuleBuilds: React.FC<ModuleBuildsProps> = ({
  deploymentId,
  buildDataHeader,
}) => {
  const [buildDataValue, setBuildDataValue] = useState<IBuild[] | null>(null)
  const [isLoading, setLoading] = useState(true)
  const [error, setError] = useState("")
  const { t } = useTranslation()

  const fetchBuildData = async () => {
    await axios
      .get(`/api/deployments/${deploymentId}`)
      .then((res) => {
        const data = Deployment.parse(res.data.deployment)
        const build = Builds.parse(data.builds)
        setBuildDataValue(build)
      })
      .catch((error) => {
        setError(t("error-load"))
        console.error(error)
      })
      .finally(() => {
        setLoading(false)
      })
  }

  useEffect(() => {
    fetchBuildData()
  }, [])

  if (isLoading) return <Loading />

  if (error) return <div className="text-center text-error">{error}</div>

  return (
    <div className="w-full card card-actions bg-base-100 overflow-x-auto rounded-sm">
      <table className="w-full divide-y divide-base-200 border-2 border-base-300 rounded-lg">
        <thead className="bg-base-300">
          <tr className="border-base-300">
            {buildDataHeader.map((tableHeader) => (
              <th
                key={tableHeader.label}
                className="px-4 py-3 text-sm font-medium text-base-content text-left tracking-wider"
              >
                {tableHeader.label}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="bg-base-100 divide-y-2 divide-base-300 ">
          {buildDataValue?.map((buildData, index) => {
            return (
              <tr
                key={index}
                className="border border-t-1 border-base-300 text-xs md:text-sm xl:text-base"
              >
                <td className="pl-4 py-3 text-xs md:text-sm">
                  {buildData.buildId}
                </td>
                <td className="pl-4 py-3 text-xs md:text-sm">
                  {buildData.action}
                </td>
                <td className="pl-4 py-3 text-xs md:text-sm">
                  {localDateFromSeconds(buildData.createdAt._seconds)}
                </td>
                <td className="pl-4 py-3 pr-2 text-xs md:text-sm">
                  {buildData.user}
                </td>
              </tr>
            )
          })}
        </tbody>
      </table>
    </div>
  )
}

export default ModuleBuilds
