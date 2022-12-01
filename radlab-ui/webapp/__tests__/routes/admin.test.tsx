import Admin from "@/routes/Admin"
import { render, screen, waitFor } from "@testing-library/react"
import "@testing-library/jest-dom"
import { BrowserRouter } from "react-router-dom"

//tests for image and button
describe("admin component", () => {
  beforeEach(() => {
    render(
      <BrowserRouter>
        <Admin />
      </BrowserRouter>,
    )
  })
  it.skip("should render the admin settings buutton", () => {
    waitFor(() => {
      const cancel_button = screen.getByTestId("cancel-button")
      expect(cancel_button).toBeInTheDocument()
      expect(cancel_button).toBeEnabled()
      const arrow = screen.getByTestId("arrow")
      expect(arrow).toBeInTheDocument()
    })
  })
})
