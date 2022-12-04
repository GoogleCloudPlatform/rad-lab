import NewDeploymentButton from "@/components/NewDeploymentButton"
import "@testing-library/jest-dom"
import { screen, render } from "@testing-library/react"
import { useTranslation } from "next-i18next"
import { BrowserRouter } from "react-router-dom"

describe("Deployment Button", () => {
  it("should render the deployment button", () => {
    const { t } = useTranslation()
    const text = t("create-new")
    render(
      <BrowserRouter>
        <NewDeploymentButton text={text} />
      </BrowserRouter>,
    )

    const button = screen.getByTestId("create-new")
    expect(button).not.toEqual(null)
    expect(button).toBeEnabled()
    expect(button).toBeInTheDocument()

    const icon = screen.getByTestId("button-icon")
    expect(icon).not.toEqual(null)
    expect(icon).toBeInTheDocument()

    const buttonName = screen.getByTestId("button-name")
    expect(buttonName).not.toEqual(null)
    expect(buttonName.innerHTML).toEqual(text)
  })
})
