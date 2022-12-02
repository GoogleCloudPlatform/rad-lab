import { INavigationItem } from "@/utils/types"
import { render, screen } from "@testing-library/react"
import Footer from "@/navigation/Footer"
import { BrowserRouter } from "react-router-dom"

describe("Footer", () => {
  it("contains links", () => {
    const routes: INavigationItem[] = [
      {
        name: "Foo",
        href: "/foo",
      },
      {
        name: "Bar",
        href: "/bar",
      },
      {
        name: "Baz",
        href: "/baz",
      },
    ]

    render(
      <BrowserRouter>
        <Footer routes={routes} />
      </BrowserRouter>,
    )

    const links = screen.getAllByRole("link")
    expect(links).toHaveLength(routes.length + 2) // Two extra for the hard-coded About us and Contact Us
  })
})
