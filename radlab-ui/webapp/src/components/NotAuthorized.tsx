import { AppConfig } from "@/utils/AppConfig"
import { useTranslation } from "next-i18next"
import { useRouter } from "next/router"
import { auth } from "@/utils/firebase"
import { userStore } from "@/store"
import { Link } from "react-router-dom"

interface INotAuthorized {
  status: boolean
}

const NotAuthorized: React.FC<INotAuthorized> = ({ status }) => {
  const { t } = useTranslation()
  const router = useRouter()
  const setUser = userStore((state) => state.setUser)

  const handleSignOut = () => {
    if (process.browser) {
      auth.signOut()
      router.push("/signin")
      setTimeout(() => setUser(null))
    }
    return <></>
  }

  // will validate and now routing temporary till we get API
  return (
    <div className="flex flex-col items-center justify-center pt-2 md:pt-5 lg:pt-5">
      <img
        src={`${AppConfig.imagePath}/access.png`}
        className="p-1 bg-base-100 bg-opacity-0 max-w-sm"
        alt="Access"
        data-testid="access-image"
      />
      <div className="font-bold text-lg text-dim text-center lg:text-xl">
        {t("access-denied")}
      </div>
      <div className="font-semibold text-sm lg:text-base text-faint text-center mt-4">
        <p>{t("access-denied-message")}</p>
        <p>{t("gcp-admin")}</p>
      </div>
      {status ? (
        <div className="font-semibold mt-4 text-md text-dim md:text-lg lg:text-lg">
          <button className="btn btn-primary" onClick={handleSignOut}>
            {t("link-signout")}
          </button>
        </div>
      ) : (
        <div className="font-semibold mt-4 text-md text-dim md:text-lg lg:text-lg">
          <Link className="btn btn-primary" to="/">
            {t("home")}
          </Link>
        </div>
      )}
    </div>
  )
}

export default NotAuthorized
