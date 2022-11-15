import { AppConfig } from "@/utils/AppConfig"
import { useTranslation } from "next-i18next"
import NewDeploymentButton from "@/components/NewDeploymentButton"

interface IEmptyState {}

const EmptyState: React.FC<IEmptyState> = ({}) => {
  const { t } = useTranslation()

  return (
    <div
      className="flex flex-col items-center justify-center pt-2 md:pt-5 lg:pt-5"
      data-testid="empty-state"
    >
      <img
        src={`${AppConfig.imagePath}/empty_state.png`}
        className="p-1 bg-base-100 bg-opacity-0 max-w-sm"
        alt="Access"
        data-testid="access-image"
      />
      <div
        className="font-semibold text-xl text-dim lg:text-large"
        data-testid="empty-state-text"
      >
        {t("no-deployment")}
      </div>
      <NewDeploymentButton text={t("create-new")} />
    </div>
  )
}

export default EmptyState
