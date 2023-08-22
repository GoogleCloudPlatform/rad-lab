import { withAuth } from "@/utils/middleware"
import { AuthedNextApiHandler } from "@/utils/types"
import { NextApiResponse } from "next"

const handler = async (req: AuthedNextApiHandler, res: NextApiResponse) => {
  const { email } = req.query

  if (req.method === "GET" && email) {
    if (!email) {
      return res.status(400).json({ message: "Please provide valid email" })
    }

    return res.status(200).json(req.user)
  }
}

export default withAuth(handler)
