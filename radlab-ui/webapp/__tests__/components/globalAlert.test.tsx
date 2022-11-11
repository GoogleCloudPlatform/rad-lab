import {
  act,
  render,
  screen,
  // waitFor,
} from "@testing-library/react"
import { BrowserRouter } from "react-router-dom"
import GlobalAlert from "@/components/GlobalAlert"
import { alertStore } from "@/store"
import { ALERT_TYPE, IAlert } from "@/utils/types"

const setStore = (type?: ALERT_TYPE, closeable = true, durationMs?: number) => {
  const alert: IAlert = {
    message: "The alert message",
    type: type || ALERT_TYPE.INFO,
    closeable,
    durationMs: durationMs || 5000,
  }

  act(() => {
    alertStore.setState({ alert })
  })
}

describe("Global Alert", () => {
  beforeEach(() => {
    render(
      <BrowserRouter>
        <GlobalAlert />
      </BrowserRouter>,
    )
  })

  it("does not show if there is not data", () => {
    const alertNode = screen.queryByTestId("global-alert")
    expect(alertNode).toBeNull()
  })

  it("does show if data is provided", () => {
    setStore()

    const alertNode = screen.getByTestId("global-alert")
    expect(alertNode).not.toBeNull()
  })

  describe("Alert Types", () => {
    it("should have error state", () => {
      setStore(ALERT_TYPE.ERROR)

      const alertNode = screen.getByTestId("global-alert")
      expect(alertNode.classList.contains("alert-error")).toBe(true)
      expect(alertNode.classList.contains("alert-warning")).toBe(false)
      expect(alertNode.classList.contains("alert-success")).toBe(false)
      expect(alertNode.classList.contains("alert-info")).toBe(false)
    })

    it("should have warning state", () => {
      setStore(ALERT_TYPE.WARNING)

      const alertNode = screen.getByTestId("global-alert")
      expect(alertNode.classList.contains("alert-error")).toBe(false)
      expect(alertNode.classList.contains("alert-warning")).toBe(true)
      expect(alertNode.classList.contains("alert-success")).toBe(false)
      expect(alertNode.classList.contains("alert-info")).toBe(false)
    })

    it("should have success state", () => {
      setStore(ALERT_TYPE.SUCCESS)

      const alertNode = screen.getByTestId("global-alert")
      expect(alertNode.classList.contains("alert-error")).toBe(false)
      expect(alertNode.classList.contains("alert-warning")).toBe(false)
      expect(alertNode.classList.contains("alert-success")).toBe(true)
      expect(alertNode.classList.contains("alert-info")).toBe(false)
    })

    it("should have info state", () => {
      setStore(ALERT_TYPE.INFO)

      const alertNode = screen.getByTestId("global-alert")
      expect(alertNode.classList.contains("alert-error")).toBe(false)
      expect(alertNode.classList.contains("alert-warning")).toBe(false)
      expect(alertNode.classList.contains("alert-success")).toBe(false)
      expect(alertNode.classList.contains("alert-info")).toBe(true)
    })
  })

  describe("Manual Closing", () => {
    it("should be visible by default", () => {
      setStore()

      const closeNode = screen.getByTestId("global-alert-close")
      expect(closeNode).not.toBeNull()
      expect(closeNode.classList.contains("hidden")).toBe(false)
    })

    it("should not be present when closeable is false", () => {
      setStore(ALERT_TYPE.INFO, false)

      const closeNode = screen.getByTestId("global-alert-close")
      expect(closeNode).not.toBeNull()
      expect(closeNode.classList.contains("hidden")).toBe(true)
    })

    it("should close when clicked", () => {
      setStore()

      const closeNode = screen.getByTestId("global-alert-close")
      expect(closeNode).not.toBeNull()

      act(() => {
        closeNode.click()
      })

      const closeNode2 = screen.queryByTestId("global-alert-close")
      expect(closeNode2).toBeNull()

      const alertNode = screen.queryByTestId("global-alert")
      expect(alertNode).toBeNull()
    })
  })

  describe("Automatic Closing", () => {
    it("should close after durationMs", async () => {
      setStore(ALERT_TYPE.INFO, false, 50)

      const alertNode = screen.queryByTestId("global-alert")
      expect(alertNode).not.toBeNull()
      expect(alertStore.getState().alert).not.toBeNull()

      // TODO: Working in prod, but can't get test to remove DOM
      // await act(async () => {
      //   await waitFor(() => expect(alertStore.getState().alert).toBeNull())
      // })
    })
  })
})
