import EmptyState from "@/components/EmptyState"
import "@testing-library/jest-dom"
import { screen, render } from "@testing-library/react"
import { useTranslation } from "next-i18next"
import { BrowserRouter } from "react-router-dom"

describe("Empty Admin State", () => {
  it("should render empty state image,text and deployment button", () => {
    const { t } = useTranslation()
    render(
      <BrowserRouter>
        <EmptyState />
      </BrowserRouter>,
    )
    const emptyBlock = screen.getByTestId("empty-state")
    expect(emptyBlock).not.toEqual(null)

    const emptyImage = screen.getByTestId("access-image")
    expect(emptyImage).toBeInTheDocument()

    const emptyText = screen.getByTestId("empty-state-text")
    expect(emptyText).not.toEqual(null)
    expect(emptyText.innerHTML).toEqual(t("no-deployment"))

    expect(screen.getByTestId("create-new")).toBeInTheDocument()
    expect(screen.getByTestId("create-new")).toBeEnabled()
  })
})
