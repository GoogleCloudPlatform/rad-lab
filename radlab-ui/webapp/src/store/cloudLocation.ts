import { create } from "zustand"
import { CloudLocation } from "@/utils/cloud"

const cloudLocation = new CloudLocation()

interface IState {
  cloudLocation: CloudLocation
}

const useStore = create<IState>(() => ({
  cloudLocation,
}))

export default useStore
