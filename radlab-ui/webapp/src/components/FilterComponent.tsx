import { DEPLOYMENT_STATUS, IModule } from "@/utils/types"
import axios from "axios"
import { useEffect, useState } from "react"
import Filter from "./Filter"

interface IFilterComponentProps {}

const FilterComponent: React.FC<IFilterComponentProps> = ({}) => {
  const [modules, setModules] = useState<IModule[] | null>(null)
  // const [isLoading, setLoading] = useState(true)

  const activeStatuses = [
    DEPLOYMENT_STATUS.SUCCESS,
    DEPLOYMENT_STATUS.PENDING,
    DEPLOYMENT_STATUS.QUEUED,
    DEPLOYMENT_STATUS.FAILURE,
    DEPLOYMENT_STATUS.EXPIRE,
    DEPLOYMENT_STATUS.CANCELLED,
    DEPLOYMENT_STATUS.INTERNAL_ERROR,
    DEPLOYMENT_STATUS.STATUS_UNKNOWN,
    DEPLOYMENT_STATUS.TIMEOUT,
    DEPLOYMENT_STATUS.WORKING,
  ]

  const fetchModules = async () => {
    await axios
      .get(`/api/github/modules`)
      .then((res) => {
        setModules(res.data)
      })
      .catch((error) => console.error(error))
      .finally(() => {
        //setLoading(false)
      })
  }

  useEffect(() => {
    fetchModules()
  }, [])

  return (
    <div className="w-full border-b border-base-300 p-4">
      <Filter
        filters={["module", "createdAt", "status"]}
        // @ts-ignore
        statuses={activeStatuses}
        modules={modules}
      />
    </div>
  )
}

export default FilterComponent
