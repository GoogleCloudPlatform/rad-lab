import Publish from "@/routes/Publish"
import { render, screen, fireEvent, waitFor } from "@testing-library/react"
import "@testing-library/jest-dom"
import { BrowserRouter } from "react-router-dom"

describe("publish modules", () => {
  beforeEach(() => {
    render(
      <BrowserRouter>
        <Publish />
      </BrowserRouter>,
    )
  })
  it.skip("should render the back button", () => {
    waitFor(() => {
      const backButton = screen.getByTestId("back-button")
      expect(backButton).toBeInTheDocument()
      expect(backButton).toBeEnabled()
    })
  })
  it.skip("should render the publish button", () => {
    waitFor(() => {
      const publishButton = screen.getByTestId("publish-button")
      expect(publishButton).toBeInTheDocument()
      expect(publishButton).toBeDisabled()
      fireEvent.click(publishButton)
      expect(publishButton).toBeEnabled()
    })
  })
  it.skip("should render the update button", () => {
    waitFor(() => {
      expect(screen.queryByTestId("update-button")).toBeNull()
      const afterClick = screen.getByTestId("update-button")
      expect(afterClick).toBeInTheDocument()
      expect(afterClick).toBeEnabled()
    })
  })
})
