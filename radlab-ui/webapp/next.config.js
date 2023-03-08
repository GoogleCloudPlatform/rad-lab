const { i18n } = require("./next-i18next.config")

const baseConfig = {
  poweredByHeader: false,
  trailingSlash: true,
  basePath: "",
  // The starter code load resources from `public` folder with `router.basePath` in React components.
  // So, the source code is "basePath-ready".
  // You can remove `basePath` if you don't need it.
  reactStrictMode: true,
  i18n,
  async rewrites() {
    return [
      {
        source: "/api/:path*",
        destination: "/api/:path*",
      },
      {
        source: "/:any*",
        destination: "/",
      },
    ]
  },
}

let nextjs
if (process.env.ANALYZE === "true") {
  /* eslint-disable import/no-extraneous-dependencies */
  const withBundleAnalyzer = require("@next/bundle-analyzer")({
    enabled: true,
  })
  nextjs = withBundleAnalyzer(baseConfig)
} else {
  nextjs = baseConfig
}

module.exports = nextjs
