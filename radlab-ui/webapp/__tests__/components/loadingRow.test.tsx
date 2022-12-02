import { render, screen } from "@testing-library/react"
import "@testing-library/jest-dom"
import LoadingRow from "@/components/LoadingRow"
import { useTranslation } from "next-i18next"

describe("Section Header", () => {
  it("should render the section title", () => {
    const { t } = useTranslation()
    const title =
      t("global-settings") ||
      t("publish-module") ||
      t("submit-deployment") ||
      t("output-progress")

    render(<LoadingRow title={title} />)

    const loaderElement = screen.getByTestId("loader")
    expect(loaderElement).not.toEqual(null)

    const loaderElementName = screen.getByTestId("loader-text")
    expect(loaderElementName).not.toEqual(null)
    expect(loaderElementName.innerHTML).toEqual(title)

    expect(screen.getByTestId("loader-element")).toBeInTheDocument()
  })
})
