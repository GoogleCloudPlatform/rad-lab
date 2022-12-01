import { AppConfig } from "@/utils/AppConfig"
import { useTranslation } from "next-i18next"
import AdminSettingsButton from "@/components/AdminSettingsButton"

interface IEmptyAdminState {}

const EmptyAdminState: React.FC<IEmptyAdminState> = ({}) => {
  const { t } = useTranslation()

  return (
    <div
      className="flex flex-col items-center justify-center pt-2 md:pt-5 lg:pt-5"
      data-testid="empty-image-block"
    >
      <img
        src={`${AppConfig.imagePath}/admin.png`}
        className="p-1 bg-base-100 bg-opacity-0 max-w-sm"
        alt="Empty Admin State"
        data-testid="empty-admin-image"
      />
      <div
        className="font-semibold text-xl text-dim lg:text-large"
        data-testid="empty-admin-text"
      >
        {t("no-published")}
      </div>
      <AdminSettingsButton text={t("admin-settings")} />
    </div>
  )
}

export default EmptyAdminState
