import { fireEvent, render, screen } from "@testing-library/react"
import "@testing-library/jest-dom"
import AdminSettingsButton from "@/components/AdminSettingsButton"
import { BrowserRouter } from "react-router-dom"
import { useTranslation } from "next-i18next"

const { t } = useTranslation()

describe("Admin Setting button", () => {
  it("should render admin settings button along with a icon", () => {
    const text = t("admin-settings")
    render(
      <BrowserRouter>
        <AdminSettingsButton text={text} />
      </BrowserRouter>,
    )

    const buttonElement = screen.getByTestId("admin-settings")
    expect(buttonElement).toBeInTheDocument()
    expect(buttonElement).toBeEnabled()

    const iconElement = screen.getByTestId("admin-button-icon")
    expect(iconElement).toBeInTheDocument()

    const buttonName = screen.getByTestId("button-name")
    expect(buttonName).not.toEqual(null)
    expect(buttonName.innerHTML).toEqual(t("admin-settings"))

    fireEvent.click(screen.getByTestId("admin-settings"))
  })
})
