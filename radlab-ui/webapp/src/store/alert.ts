import create from "zustand"
import { IAlert } from "@/utils/types"

interface IAlertState {
  alert: null | IAlert
  setAlert: (alert: null | IAlert) => void
}

const useStore = create<IAlertState>((set) => ({
  alert: null,
  setAlert: (alert) => {
    if (alert?.durationMs) {
      setTimeout(() => {
        set({ alert: null })
      }, alert.durationMs)
    }
    return set({ alert })
  },
}))

export default useStore
