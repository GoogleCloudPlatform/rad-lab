import { IDeployment } from "@/utils/types"
import { create } from "zustand"

interface IDeploymentState {
  deployments: null | IDeployment[]
  setDeployments: (deployments: null | IDeployment[]) => void
  filteredDeployments: null | IDeployment[]
  setFilteredDeployments: (deployments: null | IDeployment[]) => void
}

const deploymentStore = create<IDeploymentState>((set) => ({
  deployments: null,
  setDeployments: (deployments) => set({ deployments }),
  filteredDeployments: null,
  setFilteredDeployments: (filteredDeployments) => set({ filteredDeployments }),
}))

export default deploymentStore
