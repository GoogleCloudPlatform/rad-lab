import { IModuleCard } from "@/utils/types"

interface ModuleOverviewCardProps {
  card: IModuleCard
}

const ModuleOverviewCard: React.FC<ModuleOverviewCardProps> = ({ card }) => {
  return (
    <div className="h-26 card bg-base-100 overflow-visible card-actions rounded-lg shadow-sm">
      <div className="w-full card-body text-sm py-4 font-semibold">
        <p className="text-primary text-md">{card.title}</p>
        <p className="text-md font-medium break-words">{card.body}</p>
      </div>
    </div>
  )
}

export default ModuleOverviewCard
