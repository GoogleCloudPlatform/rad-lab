// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require("prism-react-renderer").github;
const darkCodeTheme = require("prism-react-renderer").dracula;

// TODO: Get official logo
// TODO: Update Favicon
/** @type {import('@docusaurus/types').Config} */
const config = {
  title: "RAD Lab",
  tagline:
    "RAD Lab enables users to easily deploy infrastructure on Google Cloud Platform",
  url: "https://github.com",
  // baseUrl: "/",
  baseUrl: "/rad-lab/",
  onBrokenLinks: "throw",
  onBrokenMarkdownLinks: "warn",
  favicon: "img/favicon.ico",

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: "GPS-Demos", // Usually your GitHub org/user name.
  projectName: "rad-lab-ui", // Usually your repo name.
  // organizationName: "GoogleCloudPlatform", // Usually your GitHub org/user name.
  // projectName: "rad-lab", // Usually your repo name.
  deploymentBranch: "gh-pages",

  // Even if you don't use internalization, you can use this field to set useful
  // metadata like html lang. For example, if your site is Chinese, you may want
  // to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: "en",
    locales: ["en"],
  },

  trailingSlash: true,

  presets: [
    [
      "classic",
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve("./sidebars.js"),
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          // editUrl:
          // "https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/",
        },
        theme: {
          customCss: require.resolve("./src/css/custom.css"),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      navbar: {
        logo: {
          alt: "RAD Lab",
          src: "img/logo.png",
        },
        items: [
          {
            to: "/docs/getting-started",
            label: "Documentation",
            position: "left",
          },
          {
            href: "https://github.com/GoogleCloudPlatform/rad-lab/",
            label: "GitHub",
            position: "right",
          },
        ],
      },
      footer: {
        style: "light",
        links: [
          {
            title: "Docs",
            items: [
              {
                label: "Getting Started",
                to: "/docs/getting-started",
              },
            ],
          },
          {
            title: "Deployment Methods",
            items: [
              {
                label: "Launcher",
                to: "/docs/category/rad-lab-launcher",
              },
              {
                label: "Webapp",
                to: "/docs/category/rad-lab-ui",
              },
              {
                label: "CLI",
                to: "/docs/category/terraform-cli",
              },
            ],
          },
          {
            title: "More",
            items: [
              {
                label: "GitHub",
                href: "https://github.com/GoogleCloudPlatform/rad-lab/",
              },
              //     {
              //       label: "Blog",
              //       to: "/blog",
              //     },
              //  TODO: Do we have a link to a public blog post about RAD Lab UI
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Google.`,
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
      },
    }),
};

module.exports = config;
