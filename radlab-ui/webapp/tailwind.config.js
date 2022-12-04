const themes = require("./src/styles/themes")

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    // Omit Tailwind colors. Use DaisyUI colors instead
    colors: {},
    extend: {
      animation: {
        triturn: "triturn 60s ease-in-out infinite",
      },
      keyframes: {
        triturn: {
          "0%": { transform: "rotate(0deg)" },
          "32%": { transform: "rotate(0deg)" },
          "33%": { transform: "rotate(120deg)" },
          "66%": { transform: "rotate(120deg)" },
          "67%": { transform: "rotate(240deg)" },
          "99%": { transform: "rotate(240deg)" },
          "100%": { transform: "rotate(360deg)" },
        },
      },
      screens: {
        xs: "480px",
      },
    },
  },
  variants: {
    backgroundColor: ["active"],
  },
  daisyui: {
    // https://daisyui.com/docs/themes/
    themes: [
      ...themes,
      {
        light: {
          ...require("daisyui/src/colors/themes")["[data-theme=light]"],
          "base-100": "#ffffff",
          "base-200": "#f1f5f9",
          "base-300": "#e2e8f0",

          primary: "#4885ed",
          secondary: "#3cba54",
          accent: "#f4c20d",
          neutral: "#0f172a",

          info: "#3b82f6",
          success: "#22c55e",
          warning: "#eab308",
          error: "#ef4444",
        },
      },
      {
        dark: {
          ...require("daisyui/src/colors/themes")["[data-theme=dark]"],
          primary: "#a78bfa",
          "base-content": "#f5f3ff",
        },
      },
    ],
  },
  plugins: [require("@tailwindcss/forms"), require("daisyui")],
}
