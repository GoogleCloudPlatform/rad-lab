import { INavigationItem } from "@/utils/types"
import { render, screen, fireEvent, waitFor } from "@testing-library/react"
import Navbar from "@/navigation/Navbar"
import mockUser from "@/mocks/user"
import { BrowserRouter } from "react-router-dom"

const mainRoutes: INavigationItem[] = [
  {
    name: "Main Foo",
    href: "/main-foo",
  },
]

const userRoutes: INavigationItem[] = [
  {
    name: "User Foo",
    href: "/user-foo",
  },
  {
    name: "User Bar",
    href: "/user-bar",
  },
  {
    name: "User Baz",
    href: "/user-baz",
  },
]

describe("Navbar", () => {
  it.skip("contains links", async () => {
    render(
      <BrowserRouter>
        <Navbar
          user={mockUser}
          mainRoutes={mainRoutes}
          userRoutes={userRoutes}
        />
      </BrowserRouter>,
    )

    const links = screen.getAllByRole("link")
    expect(links).toHaveLength(mainRoutes.length + 1) // The home route built into the Logo adds 1

    // Open user dropdown
    waitFor(() => {
      fireEvent.click(screen.getByTestId("user-img"))
      const moreLinks = screen.getAllByRole("link")
      expect(moreLinks).toHaveLength(userRoutes.length + mainRoutes.length + 1)
    })
  })

  it.skip("shows users avatar", async () => {
    render(
      <BrowserRouter>
        <Navbar
          user={mockUser}
          mainRoutes={mainRoutes}
          userRoutes={userRoutes}
        />
      </BrowserRouter>,
    )

    const img = await screen.findByTestId("user-img")

    // @ts-ignore
    expect(img.src).toEqual(mockUser.photoURL)
    // @ts-ignore
    expect(img.alt).toEqual(mockUser.displayName)
  })
})
