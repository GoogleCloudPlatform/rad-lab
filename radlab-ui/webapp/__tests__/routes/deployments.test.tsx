import Deployments from "@/routes/Deployments"
import { render, screen, waitFor } from "@testing-library/react"
import "@testing-library/jest-dom"
import { BrowserRouter } from "react-router-dom"
import { useTranslation } from "next-i18next"
import AdminSettingsButton from "@/components/AdminSettingsButton"
import NewDeploymentButton from "@/components/NewDeploymentButton"
import ModuleDeployment from "@/components/modules/ModuleDeployment"
import { DEPLOYMENT_HEADERS } from "@/utils/data"
import { deploymentMockData } from "@/mocks/deployments"
import { SORT_DIRECTION, SORT_FIELD } from "@/utils/types"

//tests for button and links
describe("Deployments", () => {
  const { t } = useTranslation()

  const isAdmin = true

  const MockDeployments = () => {
    return (
      <BrowserRouter>
        <Deployments />
      </BrowserRouter>
    )
  }

  beforeEach(() => {
    render(<MockDeployments />)
  })

  it("should check tabs", async () => {
    await waitFor(() => {
      const admin = screen.getByTestId("tabs")
      const myDeployments = screen.getByTestId("my-deployments")

      expect(admin).toBeInTheDocument()
      expect(myDeployments).toBeInTheDocument()
      expect(myDeployments).toBeVisible()
      expect(myDeployments).toBeEnabled()
      expect(myDeployments.textContent).toBe(t("my-deployments"))
    })

    waitFor(() => {
      const allDeployments = screen.getByTestId("all-deployments")
      isAdmin && expect(allDeployments).toBeInTheDocument()
      expect(allDeployments).toBeVisible()
      expect(allDeployments).toBeEnabled()
      expect(allDeployments.textContent).toBe(t("all-deployments"))
    })
  })

  it("should check the admin settings button", async () => {
    render(
      <BrowserRouter>
        <AdminSettingsButton text={t("admin-settings")} />
      </BrowserRouter>,
    )
    await waitFor(() => {
      const adminButton = screen.getByTestId("admin-settings")
      expect(adminButton).toBeInTheDocument()
      expect(adminButton).toBeEnabled()
      expect(adminButton).toBeVisible()
      expect(adminButton.textContent).toBe(t("admin-settings"))
    })
  })
  it("should check the create new deployment button", async () => {
    render(
      <BrowserRouter>
        <NewDeploymentButton text={t("create-new")} />
      </BrowserRouter>,
    )
    await waitFor(() => {
      const createNewDeployment = screen.getByTestId("create-new")
      expect(createNewDeployment).toBeInTheDocument()
      expect(createNewDeployment).toBeEnabled()
      expect(createNewDeployment).toBeVisible()
      expect(createNewDeployment.textContent).toBe(t("create-new"))
    })
  })

  it("should show all deployment lists", async () => {
    render(
      <BrowserRouter>
        <ModuleDeployment
          headers={DEPLOYMENT_HEADERS}
          deployments={deploymentMockData}
          defaultSortField={SORT_FIELD.CREATEDAT}
          defaultSortDirection={SORT_DIRECTION.DESC}
        />
      </BrowserRouter>,
    )
  })
})
