import { ReactNode, useEffect, useState } from "react"
import { useRouter } from "next/router"
import { auth } from "@/utils/firebase"
import { userStore } from "@/store"
import Loading from "@/navigation/Loading"
import Authenticated from "@/templates/Authenticated"
import Unauthenticated from "@/templates/Unauthenticated"
import axios from "axios"
import { isAdminResponseParser } from "@/utils/types"

type IMainProps = {
  meta: ReactNode
  children: ReactNode
}

const Main = (props: IMainProps) => {
  const router = useRouter()
  const [isLoading, setLoading] = useState(true)
  const user = userStore((state) => state.user)
  const setUser = userStore((state) => state.setUser)
  const setIsAdmin = userStore((state) => state.setIsAdmin)
  // Ensure only authenticated users can view items in the Main template
  useEffect(() => {
    const unsubscribe = auth.onAuthStateChanged((firebaseUser) => {
      setLoading(false)
      setUser(firebaseUser)
      if (!firebaseUser) {
        router.push("/signin")
        return
      }
      axios.get(`/api/user?email=${firebaseUser.email}`).then((res) => {
        const data = isAdminResponseParser.parse(res.data)
        setIsAdmin(data.isAdmin)
      })
    })
    return unsubscribe
  }, [])

  if (isLoading) return <Loading />

  if (user) return <Authenticated user={user} {...props} />

  return <Unauthenticated {...props} />
}
export { Main }
