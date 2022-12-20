import { render, screen } from "@testing-library/react"
import "@testing-library/jest-dom"
import SectionHeader from "@/components/SectionHeader"
import { useTranslation } from "next-i18next"

describe("Section Header", () => {
  it("should render the section title", () => {
    const { t } = useTranslation()
    const title = t("global-vars") || t("deploy-module") || t("select-module")

    render(<SectionHeader title={title} />)

    const titleElement = screen.getByTestId("section")
    expect(titleElement).not.toEqual(null)

    const titleElementName = screen.getByTestId("section-title")
    expect(titleElementName).not.toEqual(null)
    expect(titleElementName.innerHTML).toEqual(title)
  })
})
