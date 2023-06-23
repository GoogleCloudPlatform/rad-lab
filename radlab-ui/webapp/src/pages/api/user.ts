import { NextApiResponse } from "next"

import { withAuth } from "@/utils/middleware"
import { CustomNextApiRequest } from "@/utils/types"

const handler = async (req: CustomNextApiRequest, res: NextApiResponse) => {
  const { email } = req.query

  if (req.method === "GET" && email) {
    if (!email) {
      return res.status(400).json({ message: "Please provide valid email" })
    }

    return res.status(200).json(req.user)
  }
}

export default withAuth(handler)
