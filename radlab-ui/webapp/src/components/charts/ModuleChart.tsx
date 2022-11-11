import React from "react"
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
} from "chart.js"
import { Bar } from "react-chartjs-2"

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend)

const options = {
  responsive: true,
  plugins: {
    legend: {
      position: "top" as const,
    },
    title: {
      display: true,
      text: "Chart.js Bar Chart",
    },
  },
}

const labels = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
]

const data = {
  labels,
  datasets: [
    {
      label: "Dataset 1",
      data: [10, 20, 30, 40, 50, 35, 67, 23, 170, 40],
      backgroundColor: "#299BF9",
      borderColor: "white",
    },
  ],
}

interface ModuleChartsProps {
  deploymentId: string
}

const ModuleCharts: React.FC<ModuleChartsProps> = ({ deploymentId }) => {
  console.log({ deploymentId })

  return (
    <div className="w-full card card-actions bg-base-100 overlow-visible rounded-sm shadow-xl">
      <Bar
        className="sm:px-4 py-8 md:px-4 lg:px-4 h-full"
        options={options}
        data={data}
      />
    </div>
  )
}

export default ModuleCharts
