import { render, screen } from "@testing-library/react"

import RouteContainer from "@/components/RouteContainer"

const CHILD_TEST_ID = "child-of-route-container"

const TestComponent = () => {
  return <div data-testid={CHILD_TEST_ID}></div>
}

describe("RouteContainer", () => {
  it("should render child component", async () => {
    render(
      <RouteContainer>
        <TestComponent />
      </RouteContainer>,
    )

    const containerElement = screen.getByTestId("route-container")
    expect(containerElement).not.toEqual(null)

    const childElement = screen.getByTestId(CHILD_TEST_ID)
    expect(childElement).not.toEqual(null)
  })
})
