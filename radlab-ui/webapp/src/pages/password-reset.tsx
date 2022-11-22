import { serverSideTranslations } from "next-i18next/serverSideTranslations"
import { useTranslation } from "next-i18next"

import { Meta } from "@/layout/Meta"
import Unauthenticated from "@/templates/Unauthenticated"
import PasswordResetForm from "@/navigation/PasswordResetForm"

const PasswordReset = () => {
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
      <div className="bg-base-100 min-h-screen px-4 md:px-10">
        <div className="flex justify-center items-center min-h-screen max-w-6xl">
          <div className="mx-auto w-3/4 md:w-1/2 text-center">
            <span className="text-xl font-semibold tracking-wide">
              {ts("reset-password")}
            </span>

            <div className="sm:px-20 md:px-10 lg:px-0 xl:px-20 mt-20">
              <PasswordResetForm />
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

export default PasswordReset
