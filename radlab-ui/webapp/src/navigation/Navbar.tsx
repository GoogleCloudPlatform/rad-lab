import { Link, useMatch } from "react-router-dom"
import { useTranslation } from "next-i18next"

import { Disclosure, Menu } from "@headlessui/react"
import { MenuIcon, UserCircleIcon, XIcon } from "@heroicons/react/outline"
import { AppConfig } from "@/utils/AppConfig"
import { classNames } from "@/utils/dom"
import { User } from "firebase/auth"
import { INavigationItem } from "@/utils/types"
// @ts-ignore
import themes from "@/styles/themes"
import ThemeChanger from "@/pages/ThemeChanger"
import { userStore } from "@/store"
import { useEffect, useState } from "react"
import axios from "axios"
import { Settings } from "@/utils/types"

const Nav = ({
  user,
  mainRoutes,
  userRoutes,
}: {
  user: User
  mainRoutes: INavigationItem[]
  userRoutes: INavigationItem[]
}) => {
  const { t } = useTranslation()
  const isAdmin = userStore((state) => state.isAdmin)
  const [path, setPath] = useState("/")

  useEffect(() => {
    axios
      .get(`/api/settings`)
      .then((res) => {
        const settings = Settings.parse(res.data.settings)
        if (settings === null && isAdmin) {
          setPath("/admin")
        } else if (isAdmin) {
          setPath("/deployments")
        } else {
          setPath("/")
        }
      })
      .catch((error) => {
        console.error(error)
      })
  }, [])

  return (
    <>
      <div className="min-h-full border-b border-base-300">
        <Disclosure as="nav" className="bg-base-100 border-b border-base-200">
          {({ open }) => (
            <>
              <div className="max-w-screen-lg mx-auto px-4 sm:px-6 lg:px-0">
                <div className="flex justify-between items-center h-16">
                  <div className="flex">
                    <Link to={path}>
                      <div className="flex items-center shrink-0">
                        <img
                          className="mr-2 animate-triturn"
                          src={AppConfig.logoPath}
                          alt={t("app-title")}
                          height={36}
                          width={32}
                        />
                        <div className="text-2xl font-bold text-base-content">
                          RAD
                        </div>
                        <div className="ml-2 text-2xl font-light text-base-content">
                          Lab
                        </div>
                      </div>
                    </Link>

                    <div className="hidden sm:-my-px sm:ml-10 sm:flex sm:space-x-8">
                      {mainRoutes.map((item) => (
                        <Link
                          to={item.href}
                          key={item.name}
                          className={classNames(
                            useMatch(item.href)
                              ? "border-primary"
                              : "border-transparent text-base-content hover:border-base-300 text-faint hover:text-normal",
                            "inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium text-base-content",
                          )}
                          aria-current={
                            useMatch(item.href) ? "page" : undefined
                          }
                        >
                          {t(item.name)}
                        </Link>
                      ))}
                    </div>
                  </div>
                  <div className="hidden sm:ml-6 sm:flex sm:items-center gap-x-2">
                    <ThemeChanger themes={themes} />

                    {/* Profile dropdown */}
                    <Menu as="div" className="ml-3 relative">
                      <Menu.Button
                        data-testid="user-menu-button"
                        className="relative max-w-xs bg-base-100 flex items-center text-sm rounded-full focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary"
                      >
                        <span className="sr-only">Open user menu</span>
                        {user?.photoURL ? (
                          <img
                            data-testid="user-img"
                            className="h-8 w-8 rounded-full"
                            src={user.photoURL}
                            alt={user.displayName || ""}
                          />
                        ) : (
                          <UserCircleIcon className="w-10 text-faint" />
                        )}
                      </Menu.Button>
                      <Menu.Items className="origin-top-right absolute z-10 right-0 mt-2 w-48 rounded-md shadow-lg py-1 bg-base-100 ring-1 ring-base-300 focus:outline-none">
                        {userRoutes.map((item) => (
                          <Menu.Item key={item.name}>
                            {({ active }) => (
                              <Link
                                to={item.href}
                                key={item.name}
                                className={classNames(
                                  active
                                    ? "text-primary bg-base-100"
                                    : "text-base-content hover:bg-base-200",
                                  "block px-4 py-2 text-sm font-semibold",
                                )}
                              >
                                {t(item.name)}
                              </Link>
                            )}
                          </Menu.Item>
                        ))}
                      </Menu.Items>
                    </Menu>
                  </div>
                  <div className="-mr-2 flex items-center sm:hidden">
                    {/* Mobile menu button */}
                    <Disclosure.Button className="bg-base-100 inline-flex items-center justify-center p-2 rounded-md text-base-content hover:text-base-content hover:bg-base-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary">
                      <span className="sr-only">Open main menu</span>
                      {open ? (
                        <XIcon className="block h-6 w-6" aria-hidden="true" />
                      ) : (
                        <MenuIcon
                          className="block h-6 w-6"
                          aria-hidden="true"
                        />
                      )}
                    </Disclosure.Button>
                  </div>
                </div>
              </div>

              {/* Mobile Menu */}
              <Disclosure.Panel className="sm:hidden shadow-lg">
                <div className="pt-2 pb-3 space-y-1">
                  {mainRoutes.map((item) => (
                    <Link to={item.href} key={item.name}>
                      <Disclosure.Button
                        key={item.name}
                        as="div"
                        className={classNames(
                          useMatch(item.href)
                            ? "bg-base-100 border-primary text-primary"
                            : "border-transparent text-base-content hover:bg-base-200 hover:border-base-300",
                          "block pl-3 pr-4 py-2 border-l-4 text-base font-medium",
                        )}
                        aria-current={useMatch(item.href) ? "page" : undefined}
                      >
                        {t(item.name)}
                      </Disclosure.Button>
                    </Link>
                  ))}
                </div>
                <div className="pt-4 pb-3 border-t border-base-200">
                  <div className="flex items-center px-4">
                    <div className="flex-shrink-0">
                      {user?.photoURL ? (
                        <img
                          data-testid="user-img"
                          className="h-8 w-8 rounded-full"
                          src={user.photoURL}
                          alt={user.displayName || ""}
                        />
                      ) : (
                        <></>
                      )}
                    </div>
                    <div className="ml-3">
                      <div className="text-base font-medium text-base-content">
                        {user?.displayName}
                      </div>
                      <div className="text-sm font-medium text-base-content">
                        {user.email}
                      </div>
                    </div>
                  </div>
                  <div className="mt-3 space-y-1">
                    {userRoutes.map((item) => (
                      <Link to={item.href} key={item.name}>
                        <Disclosure.Button
                          key={item.name}
                          as="div"
                          className="block px-4 py-2 text-base font-medium text-base-content hover:text-base-content hover:bg-base-200"
                        >
                          {t(item.name)}
                        </Disclosure.Button>
                      </Link>
                    ))}
                  </div>
                </div>
              </Disclosure.Panel>
            </>
          )}
        </Disclosure>
      </div>
    </>
  )
}

export default Nav
