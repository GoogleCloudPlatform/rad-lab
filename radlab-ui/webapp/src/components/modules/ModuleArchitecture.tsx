import { useEffect } from "react"

interface ModuleArchitectureProps {
  imageURL: string
}

const ModuleArchitecture: React.FC<ModuleArchitectureProps> = ({
  imageURL,
}) => {
  useEffect(() => {}, [imageURL])

  return (
    <div className="grid grid-cols-1 md:grid-cols-2">
      <div>
        <img src={imageURL} className="p-6" />
      </div>
      <div className="mt-4">
        <span>Content</span>
      </div>
    </div>
  )
}

export default ModuleArchitecture
