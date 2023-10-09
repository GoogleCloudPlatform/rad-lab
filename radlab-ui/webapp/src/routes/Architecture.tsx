import RouteContainer from "@/components/RouteContainer"
import ModuleArchitecture from "@/components/modules/ModuleArchitecture"
import { alertStore } from "@/store"
import { ALERT_TYPE } from "@/utils/types"
import axios from "axios"
import { User } from "firebase/auth"
import { startCase } from "lodash"
import { useEffect, useState } from "react"
import { useLocation, useNavigate } from "react-router-dom"

interface ArchitectureProps {
  user: User
}

type LocationState = {
  moduleName: string
}

const Architecture: React.FC<ArchitectureProps> = ({ user }) => {
  const { state } = useLocation()
  const [navigationData, setNavigationData] = useState(false)
  const navigate = useNavigate()
  const [imageURL, setImageURL] = useState<string>("")
  const setAlert = alertStore((state) => state.setAlert)

  let selectedModuleName = ""

  const fetchArchitectureDetails = async (moduleName: string) => {
    const apiUrl = `/api/github`
    const reqBody = {
      path: `/modules/${moduleName}/images/architecture.png`,
    }
    await axios
      .post(apiUrl, reqBody, {
        //@ts-ignore
        headers: { Authorization: `Bearer ${user.accessToken}` },
      })
      .then((res) => {
        console.log("res", res)
        setImageURL(res.data._links.self)
      })
      .catch((error) => {
        console.error(error)
        setAlert({
          message: error.message,
          durationMs: 20000,
          type: ALERT_TYPE.ERROR,
        })
      })
  }

  const fetchReadmeDetails = async (moduleName: string) => {
    const apiUrl = `/api/github`
    const reqBody = {
      path: `/modules/${moduleName}/README.md`,
    }
    await axios
      .post(apiUrl, reqBody, {
        //@ts-ignore
        headers: { Authorization: `Bearer ${user.accessToken}` },
      })
      .then((res) => {
        console.log("readme", res)
        let decodeToString = Buffer.from(res.data.content, "base64").toString()
        console.log("decode", decodeToString)
      })
      .catch((error) => {
        console.error(error)
        setAlert({
          message: error.message,
          durationMs: 20000,
          type: ALERT_TYPE.ERROR,
        })
      })
  }

  if (navigationData) {
    const { moduleName } = state as LocationState
    selectedModuleName = moduleName
    fetchArchitectureDetails(selectedModuleName)
    // fetchReadmeDetails(selectedModuleName)
  }

  useEffect(() => {
    if (!state) {
      navigate("/deploy")
    } else {
      setNavigationData(true)
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
            <ModuleArchitecture imageURL={imageURL} />
          </div>
        </div>
      )}
    </RouteContainer>
  )
}

export default Architecture
