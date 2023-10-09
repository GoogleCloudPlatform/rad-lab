interface ModuleArchitectureProps {
  imageURL: string
}

const ModuleArchitecture: React.FC<ModuleArchitectureProps> = ({
  imageURL,
}) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2">
      <div>
        <img src={imageURL} />
      </div>
      <div>
        <span>Content</span>
      </div>
    </div>
  )
}

export default ModuleArchitecture
