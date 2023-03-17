import { useEffect } from "react"
import startCase from "lodash/startCase"
import { themeChange } from "theme-change"
interface ThemeChangerProps {
  themes: string[]
}

const ThemeChanger: React.FC<ThemeChangerProps> = ({ themes }) => {
  useEffect(() => {
    themeChange(false)
    // 👆 false parameter is required for react project
  }, [])

  return (
    <select className="select select-bordered" data-choose-theme>
      {themes.map((theme) => (
        <option value={theme} key={theme}>
          {startCase(theme)}
        </option>
      ))}
    </select>
  )
}

export default ThemeChanger
