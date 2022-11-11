import EmptyAdminState from "@/components/EmptyAdminState"
import "@testing-library/jest-dom"
import { screen, render } from "@testing-library/react"
import { useTranslation } from "next-i18next"
import { BrowserRouter } from "react-router-dom"

const { t } = useTranslation()

describe("Empty Admin Image", () => {
  it("should render empty state image,text and button", () => {
    render(
      <BrowserRouter>
        <EmptyAdminState />
      </BrowserRouter>,
    )
    const emptyBlock = screen.getByTestId("empty-image-block")
    expect(emptyBlock).not.toEqual(null)

    const emptyImage = screen.getByTestId("empty-admin-image")
    expect(emptyImage).toBeInTheDocument()

    const emptyText = screen.getByTestId("empty-admin-text")
    expect(emptyText).not.toEqual(null)
    expect(emptyText.innerHTML).toEqual(t("no-published"))

    expect(screen.getByTestId("admin-settings")).toBeInTheDocument()
    expect(screen.getByTestId("admin-settings")).toBeEnabled()
  })
})
