import React, { useState, useEffect, useContext, createContext } from "react"
import { useRouter } from "next/router"
import nookies from "nookies"
import { auth } from "@/utils/firebase"
import { User, onIdTokenChanged } from "firebase/auth"

const AuthContext = createContext<{ user: User | null; loading: boolean }>({
  user: null,
  loading: true,
})

export function AuthProvider({ children }: any) {
  const router = useRouter()
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState<boolean>(true)

  useEffect(() => {
    return onIdTokenChanged(auth, async (user) => {
      setLoading(false)
      if (!user) {
        setUser(null)
        nookies.destroy(null, "token")
        nookies.set(null, "token", "", { path: "/" })
        router.push("/signin")
        return
      }

      const token = await user.getIdToken()
      setUser(user)
      nookies.destroy(null, "token")
      nookies.set(null, "token", token, { path: "/" })
    })
  }, [])

  // force refresh the token every 10 minutes
  useEffect(() => {
    const handle = setInterval(async () => {
      if (user) await user.getIdToken(true)
    }, 10 * 60 * 1000)

    return () => clearInterval(handle)
  }, [])

  return (
    <AuthContext.Provider value={{ user, loading }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  return useContext(AuthContext)
}
