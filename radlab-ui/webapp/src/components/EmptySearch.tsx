import { AppConfig } from "@/utils/AppConfig"

interface IEmptySearch {
  message: string
}

const EmptySearch: React.FC<IEmptySearch> = ({ message }) => {
  return (
    <div
      className="flex flex-col items-center justify-center pt-2 md:pt-5 lg:pt-5"
      data-testid="empty-state"
    >
      <img
        src={`${AppConfig.imagePath}/emptySearch.png`}
        className="bg-base-100 bg-opacity-0 max-w-sm mx-auto"
        alt="Empty"
      />
      <div className="font-semibold text-lg text-dim lg:text-large">
        {message}
      </div>
    </div>
  )
}

export default EmptySearch
