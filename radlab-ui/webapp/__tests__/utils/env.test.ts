import { envOrFail } from "@/utils/env"

describe("env util", () => {
  it("succeeds when env var is set", () => {
    const GCP_PROJECT_ID = envOrFail(
      "NEXT_PUBLIC_GCP_PROJECT_ID",
      process.env.NEXT_PUBLIC_GCP_PROJECT_ID,
    )
    expect(GCP_PROJECT_ID).not.toBeNull()
  })

  it("fails when env var is not set", () => {
    const missingEnvVar = () => {
      envOrFail("DOES_NOT_EXIST", process.env.DOES_NOT_EXIST)
    }
    expect(missingEnvVar).toThrow(Error("DOES_NOT_EXIST is not set"))
  })
})
