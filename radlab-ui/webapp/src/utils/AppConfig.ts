import { INavigationItem, IAuthProvider } from "@/utils/types"

// Make sure you update your public/locales JSON files
export const AppConfig: {
  siteName: string
  locale: string
  logoPath: string
  imagePath: string
  theme: string
  authProviders: IAuthProvider[]
} = {
  siteName: "RAD Lab UI",
  locale: "en",
  logoPath: "/assets/images/icon.png",
  imagePath: "/assets/images",
  theme: "light",
  authProviders: ["google", "password"],
}

// These are i18n link names, put the label in the common.json file
export const AdminNavigation: INavigationItem[] = [
  { name: "link-setup", href: "/admin" },
  { name: "publish", href: "/modules" },
  { name: "deployments", href: "/deployments" },
  { name: "deploy", href: "/deploy" },
]

export const UserNavigation: INavigationItem[] = [
  { name: "deployments", href: "/deployments" },
  { name: "deploy", href: "/deploy" },
]

export const DropdownNavigation: INavigationItem[] = [
  { name: "link-signout", href: "/signout" },
]

export const FooterNavigation: INavigationItem[] = []

// Full list of scopes: https://developers.google.com/identity/protocols/oauth2/scopes
export const OAuthScopes: string[] = []
