import { useNavigate, Link } from "react-router-dom"
import RouteContainer from "@/components/RouteContainer"
import ModuleCard from "@/components/modules/ModuleCard"
import { useTranslation } from "next-i18next"
import { useEffect, useState } from "react"
import axios from "axios"
import { IModule, Modules, ALERT_TYPE } from "@/utils/types"
import { alertStore } from "@/store"
import Loading from "@/navigation/Loading"
import { envOrFail } from "@/utils/env"
import SectionHeader from "@/components/SectionHeader"

interface DeployProps {}

const GIT_URL = envOrFail(
  "NEXT_PUBLIC_GIT_URL",
  process.env.NEXT_PUBLIC_GIT_URL,
)

const GIT_BRANCH = envOrFail(
  "NEXT_PUBLIC_GIT_BRANCH",
  process.env.NEXT_PUBLIC_GIT_BRANCH,
)

const Deploy: React.FC<DeployProps> = () => {
  const navigate = useNavigate()
  const { t } = useTranslation()
  const [isLoading, setLoading] = useState(true)
  const setAlert = alertStore((state) => state.setAlert)
  const [listAvailableModules, setListAvailableModules] = useState<IModule[]>(
    [],
  )

  const handleCardClick = (moduleTitle: string) => {
    navigate("/modules/provision", {
      state: { moduleName: moduleTitle },
    })
  }

  const handleInfoClick = (moduleTitle: string) => {
    //to open git module url
    const gitPageUrl = `${GIT_URL}/tree/${GIT_BRANCH}/modules/${moduleTitle}`
    window.open(gitPageUrl, "_blank")
  }

  // get published modules for users
  const fetchPublishedModuleData = async () => {
    await axios
      .get(`/api/modules`)
      .then((res) => {
        const modules = Modules.parse(res.data.modules)
        setListAvailableModules(modules)
      })
      .catch((error) => {
        console.error(error)
        setAlert({
          message: t("error"),
          type: ALERT_TYPE.ERROR,
        })
      })
    setLoading(false)
  }

  useEffect(() => {
    fetchPublishedModuleData()
  }, [])

  const renderAvailableModules = () => {
    return listAvailableModules?.map((module) => {
      return (
        <ModuleCard
          title={module.name}
          content={module.name}
          key={module.name}
          handleCardClick={handleCardClick}
          handleInfoClick={handleInfoClick}
        />
      )
    })
  }

  if (isLoading)
    return (
      <RouteContainer>
        <Loading />
      </RouteContainer>
    )

  return (
    <RouteContainer>
      <SectionHeader title={t("deploy-module")} />
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-8">
        {renderAvailableModules()}
      </div>

      <div className="mt-10 text-center text-sm text-dim">
        If your not seeing the module you want, ask your Admin to{" "}
        <Link to="/modules" className="hover:underline">
          publish
        </Link>{" "}
        it
      </div>
    </RouteContainer>
  )
}

export default Deploy
