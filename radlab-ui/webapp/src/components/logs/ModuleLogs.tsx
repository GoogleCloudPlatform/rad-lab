import Loading from "@/navigation/Loading"
import { ILogHeader, URL, URLData } from "@/utils/types"
import axios from "axios"
import { useEffect, useState } from "react"

interface IModuleLogs {
  deploymentId: string
  tableHeaders: ILogHeader[]
}

const ModuleLogs: React.FC<IModuleLogs> = ({ deploymentId, tableHeaders }) => {
  const [lines, setLines] = useState<string[] | null>(null)
  const [loading, setLoading] = useState(true)

  const fetchData = async () => {
    await axios
      .get(`/api/deployments/${deploymentId}/logs`)
      .then((res) => {
        const urlPath = URL.parse(res.data)
        return axios.get(urlPath.url)
      })
      .then((res) => {
        const urlData = URLData.parse(res)
        const lines: string[] = urlData.data.split("\n")
        setLines(lines)
      })
      .catch((error) => {
        console.error(error)
      })
      .finally(() => {
        setLoading(false)
      })
  }

  useEffect(() => {
    fetchData()
  }, [])

  if (loading) return <Loading />

  return (
    <div className="w-full card card-actions bg-base-100 overflow-x-auto rounded-sm">
      <table className="w-full divide-y divide-base-200 border-2 border-base-300 rounded-lg block max-h-screen overflow-auto">
        <thead className="bg-base-300 sticky top-0 z-10">
          <tr className="border-base-300">
            {tableHeaders.map((tableHeader) => (
              <th
                key={tableHeader.header}
                className="px-4 py-3 text-sm font-medium text-center text-dim font-bold"
              >
                {tableHeader.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="bg-base-100 divide-y-2 divide-base-300 overflow-y-scroll w-full">
          {lines?.map((line, index) => (
            <tr key={line + index}>
              <td className="border border-base-300 px-1 py-2 text-xs font-semibold text-faint">
                {line}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

export default ModuleLogs
