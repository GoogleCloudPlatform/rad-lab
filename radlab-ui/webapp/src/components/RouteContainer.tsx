interface RouteContainerProps {}
const RouteContainer: React.FC<RouteContainerProps> = ({ children }) => {
  return (
    <div
      className="flex-grow px-4 md:px-6 lg:px-8 py-6 md:py-10 lg:py-12"
      data-testid="route-container"
    >
      <div className="max-w-screen-lg mx-auto">{children}</div>
    </div>
  )
}

export default RouteContainer
