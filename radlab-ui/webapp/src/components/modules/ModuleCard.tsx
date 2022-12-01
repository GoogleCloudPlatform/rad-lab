import React from "react"
import { InformationCircleIcon, CubeIcon } from "@heroicons/react/outline"
import startCase from "lodash/startCase"
import { userStore } from "@/store"

interface ModuleCardProps {
  title: string
  content: string
  handleCardClick: Function
  handleInfoClick: Function
}

const ModuleCard: React.FC<ModuleCardProps> = ({
  title,
  content,
  handleCardClick,
  handleInfoClick,
}) => {
  const isAdmin = userStore((state) => state.isAdmin)

  return (
    <div className="card card-actions group bg-base-100 border-2 border-base-300 overflow-visible cursor-pointer hover:border-primary hover:shadow-lg transition">
      <div className="card-body w-full">
        <div
          className="tooltip tooltip-left tooltip-primary z-10 absolute top-1 right-2"
          data-tip={`${content}`}
        >
          <button
            className="text-primary hover:cursor-pointer"
            onClick={() => handleInfoClick(title)}
            disabled={!isAdmin}
          >
            <InformationCircleIcon className="h-5 w-5" />
          </button>
        </div>
        <div
          className="grid w-full justify-items-center items-center text-center"
          onClick={() => handleCardClick(title)}
        >
          <CubeIcon className="h-16 w-16 text-primary text-dim group-hover:text-normal transition" />
          <h2 className="card-title text-dim group-hover:text-normal transition">
            {startCase(title)}
          </h2>
        </div>
      </div>
    </div>
  )
}

export default ModuleCard
