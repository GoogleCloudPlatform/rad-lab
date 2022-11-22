import {
  textColorFromDeployStatus,
  gcpLinkFromDeployment,
  localDateFromSeconds,
} from "@/utils/deployments"
import { DEPLOYMENT_STATUS } from "@/utils/types"
import { deploymentMockData } from "@/mocks/deployments"

const statusPendingData = [
  DEPLOYMENT_STATUS.PENDING,
  DEPLOYMENT_STATUS.QUEUED,
  DEPLOYMENT_STATUS.WORKING,
]

const statusSuccessData = DEPLOYMENT_STATUS.SUCCESS

const statusWarningData = [
  DEPLOYMENT_STATUS.STATUS_UNKNOWN,
  DEPLOYMENT_STATUS.EXPIRE,
  DEPLOYMENT_STATUS.CANCELLED,
]

const statusErrorData = [
  DEPLOYMENT_STATUS.TIMEOUT,
  DEPLOYMENT_STATUS.FAILURE,
  DEPLOYMENT_STATUS.INTERNAL_ERROR,
]

describe("deployments util", () => {
  it("status text color", () => {
    statusPendingData.forEach((status) => {
      const statusPending = textColorFromDeployStatus(status)
      expect(statusPending).toStrictEqual("info")
    })

    const statusSuccess = textColorFromDeployStatus(statusSuccessData)
    expect(statusSuccess).not.toBeNull()
    expect(statusSuccess).toStrictEqual("success")

    statusWarningData.forEach((status) => {
      const statusWarning = textColorFromDeployStatus(status)
      expect(statusWarning).toStrictEqual("warning")
    })

    statusErrorData.forEach((status) => {
      const statusError = textColorFromDeployStatus(status)
      expect(statusError).toStrictEqual("error")
    })
  })

  it("gcp link", () => {
    const gcpLink = gcpLinkFromDeployment(deploymentMockData)
    expect(gcpLink).toStrictEqual(
      "https://console.cloud.google.com/welcome?project=radlab-data-science-32fa",
    )
  })

  it("local date from seconds", () => {
    const gcpLink = localDateFromSeconds(deploymentMockData.createdAt._seconds)
    expect(gcpLink).toStrictEqual("9/28/2022")
  })
})
