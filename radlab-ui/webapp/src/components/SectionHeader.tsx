interface SectionHeaderProps {
  title: string
}

const SectionHeader: React.FC<SectionHeaderProps> = ({ title }) => {
  return (
    <div
      className="w-full flex justify-between items-center text-lg font-medium border-l-4 border-primary pl-4 py-3 mb-6"
      data-testid="section"
    >
      <span className="text-dim" data-testid="section-title">
        {title}
      </span>
    </div>
  )
}

export default SectionHeader
