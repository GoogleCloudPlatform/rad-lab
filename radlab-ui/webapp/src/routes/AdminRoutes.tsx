import NotAuthorized from "@/components/NotAuthorized"

interface IAdmin {
  admin: boolean | null
}

const AdminRoutes: React.FC<IAdmin> = ({ admin, children }) => {
  if (!admin) return <NotAuthorized status={false} />
  return <>{children}</>
}

export default AdminRoutes
