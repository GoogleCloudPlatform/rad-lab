import { User } from "firebase/auth"
import { BrowserRouter } from "react-router-dom"
import AppRouter from "@/routes/AppRouter"
import Footer from "@/navigation/Footer"
import Navbar from "@/navigation/Navbar"
import {
  AdminNavigation,
  DropdownNavigation,
  UserNavigation,
  FooterNavigation,
} from "@/utils/AppConfig"
import GlobalAlert from "@/components/GlobalAlert"
import { useEffect, useState } from "react"
import axios from "axios"
import NotAuthorized from "@/components/NotAuthorized"
import Loading from "@/navigation/Loading"
import { isAdminResponseParser } from "@/utils/types"
import { userStore } from "@/store"

interface AuthenticatedProps {
  meta: React.ReactNode
  children: React.ReactNode
  user: User
}

const Authenticated: React.FC<AuthenticatedProps> = ({
  meta,
  user,
  // children, // NextJS children Nodes
}) => {
  const [userIdentity, setUserIdentity] = useState(false)
  const [loading, setLoading] = useState(true)
  const setIsAdmin = userStore((state) => state.setIsAdmin)
  const isAdmin = userStore((state) => state.isAdmin)

  useEffect(() => {
    axios
      .get(`/api/user?email=${user.email}`)
      .then((res) => {
        const data = isAdminResponseParser.parse(res.data)
        setIsAdmin(data.isAdmin)
        setUserIdentity(true)
      })
      .catch(() => {
        setUserIdentity(false)
      })
      .finally(() => {
        setLoading(false)
      })
  }, [])

  if (loading) return <Loading />
  if (!userIdentity) return <NotAuthorized status={true} />
  return (
    <BrowserRouter>
      <div className="min-h-screen w-full text-base-content bg-base-200 relative">
        {meta}

        <div className="absolute top-20 z-10 flex justify-center w-full">
          <div className="max-w-xl mx-4">
            <GlobalAlert />
          </div>
        </div>

        <div className="min-h-screen flex flex-col">
          <Navbar
            user={user}
            mainRoutes={isAdmin ? AdminNavigation : UserNavigation}
            userRoutes={DropdownNavigation}
          />

          <AppRouter />

          <Footer routes={FooterNavigation} />
        </div>
      </div>
    </BrowserRouter>
  )
}

export default Authenticated
