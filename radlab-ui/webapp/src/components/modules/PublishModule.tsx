import { CubeIcon } from "@heroicons/react/outline"
import React, { useEffect, useState } from "react"
import { classNames } from "@/utils/dom"
import startCase from "lodash/startCase"

interface IPublishModuleProps {
  title: string
  handleButtonClick: Function
  defaultSelectedModules: string[]
}

const PublishModule: React.FC<IPublishModuleProps> = ({
  title,
  handleButtonClick,
  defaultSelectedModules,
}) => {
  const [active, setActive] = useState(false)

  const getPublishedModules = defaultSelectedModules.includes(title)

  useEffect(() => {
    if (getPublishedModules) {
      setActive(true)
    }
  }, [getPublishedModules])
  return (
    <button
      className={classNames(
        "w-full bg-base-200 shadow rounded-lg text-primary inline-flex items-center py-4 px-6 gap-2",
        "hover:text-normal transition",
        active ? "outline shadow-xl text-normal" : "text-dim",
      )}
      onClick={() => {
        setActive(!active)
        handleButtonClick(!active, title)
      }}
    >
      <CubeIcon className="h-6 text-primary" />
      {startCase(title)}
    </button>
  )
}

export default PublishModule
