import { serverSideTranslations } from "next-i18next/serverSideTranslations"
import { useTranslation } from "next-i18next"

import { Meta } from "@/layout/Meta"
import Unauthenticated from "@/templates/Unauthenticated"
import SignInForm from "@/navigation/SignInForm"
import { AppConfig } from "@/utils/AppConfig"

const Signin = () => {
  const { t } = useTranslation("common")
  const { t: ts } = useTranslation("signin")

  return (
    <Unauthenticated
      meta={
        <Meta
          title={ts("signin-title")}
          description={ts("signin-description")}
        />
      }
    >
      <div className="bg-base-100 min-h-screen px-0 md:px-0">
        <div className="flex flex-col sm:flex-row justify-center items-center w-full sm:min-h-screen">
          <div className="flex w-full sm:w-1/2 items-center sm:min-h-screen bg-primary-focus">
            <div className="py-10 mx-auto w-3/4 md:w-1/2 text-center">
              <div className="flex items-center justify-center">
                <img
                  className="h-10 w-auto mr-2 animate animate-triturn"
                  src={AppConfig.logoPath}
                  alt={t("app-title")}
                />
                <div className="text-2xl font-bold text-primary-content">
                  RAD
                </div>
                <div className="ml-2 text-2xl font-light text-primary-content">
                  Lab
                </div>
              </div>
              <div className="mt-4 text-primary-content">
                {t("app-description")}
              </div>
            </div>
          </div>

          <div className="flex justify-center w-full sm:w-1/2 items-center sm:min-h-screen py-10">
            <div className="sm:px-5 md:px-10 xl:px-20 md:w-3/4">
              <SignInForm authOptions={AppConfig.authProviders} />
            </div>
          </div>
        </div>
      </div>
    </Unauthenticated>
  )
}

export async function getServerSideProps({ locale }: { locale: string }) {
  return {
    props: {
      ...(await serverSideTranslations(locale, ["common", "signin"])),
    },
  }
}

export default Signin
