// https://github.com/pmndrs/zusta
import { create } from "zustand"

import { User } from "firebase/auth"

interface IUserState {
  user: null | User
  isAdmin: boolean | null
  setUser: (user: null | User) => void
  setIsAdmin: (isAdmin: null | boolean) => void
}

const useStore = create<IUserState>((set) => ({
  user: null,
  isAdmin: null,
  setUser: (user) => set({ user }),
  setIsAdmin: (isAdmin) => set({ isAdmin }),
}))

export default useStore
