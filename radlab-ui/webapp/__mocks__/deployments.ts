import { DEPLOYMENT_STATUS, IDeployment } from "@/utils/types"

export const deploymentMockData: IDeployment = {
  id: "",
  createdAt: { _seconds: 1664378694, _nanoseconds: 972000000 },
  variables: {},
  status: DEPLOYMENT_STATUS.QUEUED,
  updatedAt: { _seconds: 1664378694, _nanoseconds: 973000000 },
  projectId: "radlab-data-science-32fa",
  deployedByEmail: "",
  module: "",
  builds: [],
  deploymentId: "",
}
