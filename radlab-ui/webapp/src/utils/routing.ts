import { NextRouter } from "next/router"

/**
 * @param router A React Router instance
 * @returns boolean. True if href matches the current route
 */
export const isCurrentRoute = (router: NextRouter) => (href: string) =>
  href === router.pathname
