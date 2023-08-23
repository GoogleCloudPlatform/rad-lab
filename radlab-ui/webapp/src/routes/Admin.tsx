import { useNavigate } from "react-router-dom"
import { ArrowLeftIcon } from "@heroicons/react/outline"
import { DEFAULT_ADMIN_VARS } from "@/utils/data"
import RouteContainer from "@/components/RouteContainer"
import DefaultCreateForm from "@/components/forms/DefaultCreateForm"
import { parseVarsFile } from "@/utils/terraform"
import { useTranslation } from "next-i18next"
import axios from "axios"
import { useEffect, useState } from "react"
import Loading from "@/navigation/Loading"
import SectionHeader from "@/components/SectionHeader"
import LoadingRow from "@/components/LoadingRow"
import { ISettings, IVariables } from "@/utils/types"

interface IProvisionDefaultProps {}

const ProvisionDefault: React.FC<IProvisionDefaultProps> = ({}) => {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [isLoading, setLoading] = useState(true)
  const [defaultSettingVarsData, setDefaultSettingVarsData] =
    useState<IVariables>({})
  const formVariableData = DEFAULT_ADMIN_VARS
  const [submitLoading, setSubmitLoading] = useState(false)

  const handleBackClick = () => {
    navigate("/deployments")
  }

  // To check Admin settings updated if not thern redirect to default setting
  const fetchAdminSettings = async () => {
    setLoading(true)
    // fetch regions data
    try {
      await axios
        .get(`/api/settings`)
        .then((res) => {
          const settings = res.data.settings as ISettings | null
          if (settings) {
            setDefaultSettingVarsData(settings.variables)
          }
        })
        .catch((error) => {
          console.error(error)
        })
        .finally(() => {
          setLoading(false)
        })
    } catch (error) {
      console.error(error)
    }
  }

  useEffect(() => {
    fetchAdminSettings()
  }, [])

  if (isLoading)
    return (
      <RouteContainer>
        <Loading />
      </RouteContainer>
    )

  return (
    <RouteContainer>
      <SectionHeader title={t("global-vars")} />
      <div className="card bg-base-100 border border-base-300 rounded-lg p-2 sm:min-h-full">
        <div className="w-full flex mb-6">
          <button
            className="btn btn-link gap-2"
            onClick={handleBackClick}
            data-testid="cancel-button"
          >
            <ArrowLeftIcon className="h-5 w-5" data-testid="arrow" />
            {t("cancel")}
          </button>
        </div>
        {submitLoading && <LoadingRow title={t("global-settings")} />}
        <div className="justify-center w-full mb-8">
          <div className="flex w-full sm:w-2/5 mx-auto">
            {console.log("formVariables", parseVarsFile(formVariableData))}
            {console.log("defaultSettingVariables", defaultSettingVarsData)}
            <DefaultCreateForm
              formVariables={parseVarsFile(formVariableData)}
              defaultSettingVariables={defaultSettingVarsData}
              handleLoading={setSubmitLoading}
            />
          </div>
        </div>
      </div>
    </RouteContainer>
  )
}

export default ProvisionDefault
