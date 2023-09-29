import { DEPLOYMENT_STATUS, IDeployment } from "@/utils/types"

type DEPLOY_STATUS_COLOR = "success" | "info" | "error" | "warning"

export const textColorFromDeployStatus = (
  status?: DEPLOYMENT_STATUS,
): DEPLOY_STATUS_COLOR => {
  switch (status) {
    case DEPLOYMENT_STATUS.PENDING:
    case DEPLOYMENT_STATUS.QUEUED:
    case DEPLOYMENT_STATUS.WORKING:
      return "info"

    case DEPLOYMENT_STATUS.SUCCESS:
      return "success"

    case DEPLOYMENT_STATUS.STATUS_UNKNOWN:
    case DEPLOYMENT_STATUS.EXPIRE:
    case DEPLOYMENT_STATUS.CANCELLED:
      return "warning"

    case DEPLOYMENT_STATUS.TIMEOUT:
    case DEPLOYMENT_STATUS.FAILURE:
    case DEPLOYMENT_STATUS.INTERNAL_ERROR:
      return "error"

    default:
      return "info"
  }
}

export const gcpLinkFromDeployment = (deployment: IDeployment) =>
  `https://console.cloud.google.com/welcome?project=${deployment.projectId}`

export const localDateFromSeconds = (seconds: number) =>
  new Date(seconds * 1000).toLocaleDateString()

export const capitalizeLetter = (word: string) => {
  const result = word.charAt(0).toUpperCase() + word.slice(1)
  return result
}
