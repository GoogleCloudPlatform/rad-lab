import RouteContainer from "@/components/RouteContainer"
import ModuleArchitecture from "@/components/modules/ModuleArchitecture"
import axios from "axios"
import { startCase } from "lodash"
import { useEffect, useState } from "react"
import { useLocation, useNavigate } from "react-router-dom"

interface ArchitectureProps {}

type LocationState = {
  moduleName: string
}

const Architecture: React.FC<ArchitectureProps> = () => {
  const { state } = useLocation()
  const [navigationData, setNavigationData] = useState(false)
  const navigate = useNavigate()

  let selectedModuleName = ""

  if (navigationData) {
    const { moduleName } = state as LocationState
    selectedModuleName = moduleName
  }

  const fetchArchitectureDetails = async () => {
    const apiUrl = `/api/github/${selectedModuleName}}/images/architecture`

    await axios.get(apiUrl).then((res) => {
      console.log("res", res)
    })
  }

  useEffect(() => {
    fetchArchitectureDetails()
  })

  useEffect(() => {
    if (!state) {
      navigate("/deploy")
    } else {
      setNavigationData(true)
      // if (selectedModuleName) {
      //   fetchModuleFormData()
      // }
    }
  }, [selectedModuleName])

  return (
    <RouteContainer>
      {navigationData && selectedModuleName && (
        <div className="p-10">
          <div className="card bg-base-100 rounded-md mt-4">
            <div className="mt-2 flex justify-center text-md font-semibold text-dim">
              {startCase(selectedModuleName)}
            </div>
            <ModuleArchitecture />
          </div>
        </div>
      )}
    </RouteContainer>
  )
}

export default Architecture
