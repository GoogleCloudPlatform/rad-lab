import { useRouter } from "next/router"
import { auth } from "@/utils/firebase"
import { userStore } from "@/store"

const Signout = () => {
  const router = useRouter()
  const setUser = userStore((state) => state.setUser)

  if (process.browser) {
    auth.signOut()
    router.push("/signin")
    setTimeout(() => setUser(null))
  }
  return <></>
}

export default Signout
