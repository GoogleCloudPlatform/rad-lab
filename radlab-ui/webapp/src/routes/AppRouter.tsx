import { Route, Routes } from "react-router-dom"
import Home from "@/routes/Home"
import SignOut from "@/routes/SignOut"
import NotFound from "@/routes/NotFound"
import ProvisionModule from "@/routes/ProvisionModule"
import Deploy from "@/routes/Deploy"
import Publish from "@/routes/Publish"
import Deployments from "@/routes/Deployments"
import DeploymentDetails from "@/routes/DeploymentDetails"
import Admin from "@/routes/Admin"
import React from "react"
import { userStore } from "@/store"
import AdminRoutes from "@/routes/AdminRoutes"
import UpdateModule from "@/routes/UpdateModule"
import ProvisionPublishModule from "@/routes/ProvisionPublishModule"
import Architecture from "@/routes/Architecture"

interface AppRouterProps {}

const AppRouter: React.FC<AppRouterProps> = ({}) => {
  const isAdmin = userStore((state) => state.isAdmin)

  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/signout" element={<SignOut />} />

      <Route
        path="/admin"
        element={
          <AdminRoutes admin={isAdmin}>
            <Admin />
          </AdminRoutes>
        }
      />

      <Route path="/deploy" element={<Deploy />} />

      <Route path="/deployments" element={<Deployments />} />
      <Route path="/deployments/:deployId" element={<DeploymentDetails />} />
      <Route path="/deployments/:deployId/update" element={<UpdateModule />} />

      <Route path="/modules/provision" element={<ProvisionModule />} />
      <Route path="/modules/architecture" element={<Architecture />} />
      <Route
        path="/modules"
        element={
          <AdminRoutes admin={isAdmin}>
            <Publish />
          </AdminRoutes>
        }
      />
      <Route
        path="/modules/publish/provision"
        element={
          <AdminRoutes admin={isAdmin}>
            <ProvisionPublishModule />
          </AdminRoutes>
        }
      />

      <Route path="*" element={<NotFound />} />
    </Routes>
  )
}

export default AppRouter
