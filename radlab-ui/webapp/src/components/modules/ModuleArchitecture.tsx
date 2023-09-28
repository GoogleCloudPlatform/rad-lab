import { AppConfig } from "@/utils/AppConfig"

interface ModuleArchitectureProps {}

const ModuleArchitecture: React.FC<ModuleArchitectureProps> = () => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2">
      <div>
        <img src={`${AppConfig.imagePath}/access.png`} />
      </div>
      <div>
        <span>Content</span>
      </div>
    </div>
  )
}

export default ModuleArchitecture
