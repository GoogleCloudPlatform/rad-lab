import { gcpLinkFromDeployment } from "@/utils/deployments"
import { DEPLOYMENT_STATUS, IDeployment } from "@/utils/types"
import { useTranslation } from "next-i18next"

interface ProjectLinkProps {
  deployment: IDeployment
}

const ProjectLink: React.FC<ProjectLinkProps> = ({ deployment }) => {
  const { t } = useTranslation()

  return (
    <>
      {deployment.status === DEPLOYMENT_STATUS.SUCCESS &&
      !deployment.deletedAt ? (
        <a
          href={gcpLinkFromDeployment(deployment)}
          rel="noopener"
          target="_blank"
          className="hover:underline transition"
        >
          {deployment.projectId}
        </a>
      ) : (
        <span
          className="tooltip tooltip-primary"
          data-tip={t("gcp-status-progress-message")}
        >
          <span className="cursor-default text-dim">
            {deployment.projectId}
          </span>
        </span>
      )}
    </>
  )
}

export default ProjectLink
