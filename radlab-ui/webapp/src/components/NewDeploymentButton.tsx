import { FolderAddIcon } from "@heroicons/react/outline"
import { useNavigate } from "react-router-dom"

interface NewDeploymentButtonProps {
  text: string
}

const NewDeploymentButton: React.FC<NewDeploymentButtonProps> = ({ text }) => {
  const navigate = useNavigate()

  return (
    <button
      className="btn btn-link gap-1 hover:no-underline"
      data-testid="create-new"
      onClick={() => navigate("/deploy")}
    >
      <FolderAddIcon className="h-6 w-6" data-testid="button-icon" />
      <span data-testid="button-name">{text}</span>
    </button>
  )
}

export default NewDeploymentButton
