import { serverSideTranslations } from "next-i18next/serverSideTranslations"
import { useTranslation } from "next-i18next"

import { Meta } from "@/layout/Meta"
import { Main } from "@/templates/Main"

const Index = () => {
  const { t: tc } = useTranslation("common")

  return (
    <Main
      children
      meta={
        <Meta title={tc("app-title")} description={tc("app-description")} />
      }
    ></Main>
  )
}

export default Index

export async function getServerSideProps({ locale }: { locale: string }) {
  return {
    props: {
      ...(await serverSideTranslations(locale, ["common", "home"])),
    },
  }
}
