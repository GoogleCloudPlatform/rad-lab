import Deployments from "@/routes/Deployments"
import { render, screen, waitFor } from "@testing-library/react"
import "@testing-library/jest-dom"
import { BrowserRouter } from "react-router-dom"

//tests for button and links
describe("List module", () => {
  beforeEach(() => {
    render(
      <BrowserRouter>
        <Deployments />
      </BrowserRouter>,
    )
  })

  it.skip("should check admin settings button and create new button", () => {
    waitFor(() => {
      const admin = screen.getByTestId("admin-settings")
      expect(admin).toBeInTheDocument()
      expect(admin).toBeEnabled()
      const create = screen.getByTestId("create-new")
      expect(create).toBeInTheDocument()
      expect(create).toBeEnabled()
    })
  })

  it.skip("should check the the links", () => {
    waitFor(() => {
      const linkElement1 = screen.getByTestId("all-deployments")
      expect(linkElement1).toBeInTheDocument()
      expect(linkElement1).toBeEnabled()
      const linkElement2 = screen.getByTestId("my-deployments")
      expect(linkElement2).toBeInTheDocument()
      expect(linkElement2).toBeEnabled()
    })
  })
})
