import { useEffect } from "react"
import { AppProps } from "next/app"
import { appWithTranslation } from "next-i18next"
import { initializeAppCheck, ReCaptchaV3Provider } from "firebase/app-check"
import { app } from "@/utils/firebase"

import "../styles/global.css"

let initRecaptcha = false

const MyApp = ({ Component, pageProps }: AppProps) => {
  // Enable Firebase App Check
  const recaptchaKey = process.env.NEXT_PUBLIC_RECAPTCHA_PUBLIC_SITE_KEY
  useEffect(() => {
    if (recaptchaKey && !initRecaptcha) {
      initializeAppCheck(app, {
        provider: new ReCaptchaV3Provider(recaptchaKey),
        isTokenAutoRefreshEnabled: true,
      })
    }
    initRecaptcha = true
  })

  return (
    <div suppressHydrationWarning className="min-h-screen h-full">
      {typeof window === "undefined" ? null : <Component {...pageProps} />}
    </div>
  )
}

export default appWithTranslation(MyApp)
