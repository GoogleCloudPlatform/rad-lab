import { useNavigate } from "react-router-dom"
import { CogIcon } from "@heroicons/react/outline"

interface AdminSettingsButtonProps {
  text: string
}

const AdminSettingsButton: React.FC<AdminSettingsButtonProps> = ({ text }) => {
  const navigate = useNavigate()

  return (
    <button
      className="btn btn-link gap-1 hover:no-underline"
      onClick={() => navigate("/modules")}
      data-testid="admin-settings"
      role="admin-button"
    >
      <CogIcon className="h-5 w-5" data-testid="admin-button-icon" />
      <span data-testid="button-name">{text}</span>
    </button>
  )
}

export default AdminSettingsButton
