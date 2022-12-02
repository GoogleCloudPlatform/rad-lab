import { useTranslation } from "next-i18next"

interface NotFoundProps {}

const NotFound: React.FC<NotFoundProps> = ({}) => {
  const { t } = useTranslation()

  return (
    <div className="flex items-center justify-center pt-24 md:pt-48 lg:pt-72">
      <div className="font-bold text-3xl border-r px-6">404</div>
      <div className="px-6 text-lg">{t("not-found")}</div>
    </div>
  )
}

export default NotFound
