import Loading from "@/navigation/Loading"

interface LoadingRowProps {
  title: string
}

const LoadingRow: React.FC<LoadingRowProps> = ({ title }) => {
  return (
    <div
      className="flex flex-col space-y-2 w-full text-center m-2"
      data-testid="loader"
    >
      <Loading />
      <p className="text-md text-dim font-semibold" data-testid="loader-text">
        {title}
      </p>
    </div>
  )
}

export default LoadingRow
