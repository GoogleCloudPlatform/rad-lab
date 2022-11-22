import { useEffect } from "react"
import { useNavigate } from "react-router-dom"

interface HomeProps {}

const Home: React.FC<HomeProps> = () => {
  const navigate = useNavigate()

  // Route immediately to /deployments
  useEffect(() => navigate("/deployments"), [])

  return <></>
}

export default Home
