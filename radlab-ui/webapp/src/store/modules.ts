import { IModule } from "@/utils/types"
import { create } from "zustand"

interface IModuleState {
  moduleNames: null | IModule[]
  setModuleNames: (deployments: null | IModule[]) => void
}

const moduleNamesStore = create<IModuleState>((set) => ({
  moduleNames: null,
  setModuleNames: (moduleNames) => set({ moduleNames }),
}))

export default moduleNamesStore
