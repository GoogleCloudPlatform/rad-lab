import { parseVarsFile, groupVariables } from "@/utils/terraform"
import { DATA_SCIENCE_VARS } from "@/mocks/terraform"
import { IUIVariable } from "@/utils/types"

const getByName = (name: string, vars: IUIVariable[]): IUIVariable => {
  const variable = vars.find((v) => v.name === name)
  if (!variable) throw new Error(`Variable ${name} is not found`)
  return variable
}

describe("terraform util", () => {
  it("parses all variables", () => {
    const parsed = parseVarsFile(DATA_SCIENCE_VARS)
    const VAR_REGEX = /variable \"[a-z_]*\"/gi
    const varDeclarations = DATA_SCIENCE_VARS.matchAll(VAR_REGEX)
    const varCount = [...varDeclarations].length

    expect(parsed).toHaveLength(varCount)
  })

  it("parses groups", () => {
    const parsed = parseVarsFile(DATA_SCIENCE_VARS)

    const zone = getByName("zone", parsed)
    expect(zone.group).toStrictEqual(1)

    const trusted_users = getByName("trusted_users", parsed)
    expect(trusted_users.group).toStrictEqual(2)

    const subnet_name = getByName("subnet_name", parsed)
    expect(subnet_name.group).toStrictEqual(3)

    const enable_gpu_driver = getByName("enable_gpu_driver", parsed)
    expect(enable_gpu_driver.group).toStrictEqual(11)

    const set_trustedimage_project_policy = getByName(
      "set_trustedimage_project_policy",
      parsed,
    )
    expect(set_trustedimage_project_policy.group).toBeNull()
  })

  it("parses order", () => {
    const parsed = parseVarsFile(DATA_SCIENCE_VARS)

    const zone = getByName("zone", parsed)
    expect(zone.order).toStrictEqual(1)

    const trusted_users = getByName("trusted_users", parsed)
    expect(trusted_users.order).toStrictEqual(1)

    const enable_gpu_driver = getByName("enable_gpu_driver", parsed)
    expect(enable_gpu_driver.order).toStrictEqual(20)

    const subnet_name = getByName("subnet_name", parsed)
    expect(subnet_name.order).toBeNull()

    const set_trustedimage_project_policy = getByName(
      "set_trustedimage_project_policy",
      parsed,
    )
    expect(set_trustedimage_project_policy.order).toStrictEqual(1)
  })

  it("parses options", () => {
    const parsed = parseVarsFile(DATA_SCIENCE_VARS)

    const zone = getByName("zone", parsed)
    expect(zone.options).not.toBeNull()
    expect(zone.options).toHaveLength(4)
    expect(zone.options?.[1]).toStrictEqual("us-east1-a")

    const trusted_users = getByName("trusted_users", parsed)
    expect(trusted_users.options).toBeNull()
  })

  it("parses descriptions when no UIMeta is present", () => {
    const parsed = parseVarsFile(DATA_SCIENCE_VARS)

    const billing_account_id = getByName("billing_account_id", parsed)
    expect(billing_account_id.description).not.toBeNull()
  })

  it("parses type", () => {
    // Write test for parsing various types (string, number, bool, set(string), list(string), etc)
    const parsed = parseVarsFile(DATA_SCIENCE_VARS)

    const billing_account_id = getByName("billing_account_id", parsed)
    expect(billing_account_id.type).not.toBeNull()
    expect(billing_account_id.type).toStrictEqual("string")

    const boot_disk_size_gb = getByName("boot_disk_size_gb", parsed)
    expect(boot_disk_size_gb.type).not.toBeNull()
    expect(boot_disk_size_gb.type).toStrictEqual("number")

    const create_container_image = getByName("create_container_image", parsed)
    expect(create_container_image.type).not.toBeNull()
    expect(create_container_image.type).toStrictEqual("bool")

    const trusted_users = getByName("trusted_users", parsed)
    expect(trusted_users.type).not.toBeNull()
    expect(trusted_users.type).toStrictEqual("set(string)")

    const billing_budget_labels = getByName("billing_budget_labels", parsed)
    expect(billing_budget_labels.type).not.toBeNull()
    expect(billing_budget_labels.type).toStrictEqual("map(string)")

    const billing_budget_alert_spent_percents = getByName(
      "billing_budget_alert_spent_percents",
      parsed,
    )
    expect(billing_budget_alert_spent_percents.type).not.toBeNull()
    expect(billing_budget_alert_spent_percents.type).toStrictEqual(
      "list(number)",
    )
  })

  it("parses required", () => {
    // Write test for parsing required field
    // NOTE: // In TF, desription = "" is how we say it's optional
    const parsed = parseVarsFile(DATA_SCIENCE_VARS)

    const billing_account_id = getByName("billing_account_id", parsed)
    expect(billing_account_id.default).toBeNull()
    expect(billing_account_id.required).toBe(true)

    const zone = getByName("zone", parsed)
    expect(zone.default).not.toBeNull()
    expect(zone.default).toStrictEqual("us-east4-c")
    expect(zone.required).toBe(true)
  })

  it("parses name", () => {
    // Write test for parsing name field
    const parsed = parseVarsFile(DATA_SCIENCE_VARS)

    const billing_account_id = getByName("billing_account_id", parsed)
    expect(billing_account_id.name).not.toBeNull()
    expect(billing_account_id.name).toStrictEqual("billing_account_id")

    const trusted_users = getByName("trusted_users", parsed)
    expect(trusted_users.name).not.toBeNull()
    expect(trusted_users.name).toStrictEqual("trusted_users")
  })

  it("parses display", () => {
    // Write test for parsing display field (when we start case it)
    const parsed = parseVarsFile(DATA_SCIENCE_VARS)

    const billing_account_id = getByName("billing_account_id", parsed)
    expect(billing_account_id.display).not.toBeNull()
    expect(billing_account_id.display).toStrictEqual("Billing Account Id")

    const trusted_users = getByName("trusted_users", parsed)
    expect(trusted_users.display).not.toBeNull()
    expect(trusted_users.display).toStrictEqual("Trusted Users")
  })

  it("parses default", () => {
    // Write test for parsing default field
    const parsed = parseVarsFile(DATA_SCIENCE_VARS)

    const billing_account_id = getByName("billing_account_id", parsed)
    expect(billing_account_id.default).toBeNull()

    const boot_disk_size_gb = getByName("boot_disk_size_gb", parsed)
    expect(boot_disk_size_gb.default).not.toBeNull()
    expect(boot_disk_size_gb.default).toStrictEqual(100)

    const set_external_ip_policy = getByName("set_external_ip_policy", parsed)
    expect(set_external_ip_policy.default).not.toBeNull()
    expect(set_external_ip_policy.default).toBe(false)
  })

  describe("updatesafe parsing", () => {
    it("defaults to false if not annotated", () => {
      const parsed = parseVarsFile(DATA_SCIENCE_VARS)

      const billing_account_id = getByName("billing_account_id", parsed)
      expect(billing_account_id.updateSafe).toStrictEqual(false)
    })

    it("does not matter where in UIMeta it is", () => {
      const parsed = parseVarsFile(DATA_SCIENCE_VARS)

      const set_shielded_vm_policy = getByName("set_shielded_vm_policy", parsed)
      expect(set_shielded_vm_policy.updateSafe).toStrictEqual(true)

      const set_trustedimage_project_policy = getByName(
        "set_trustedimage_project_policy",
        parsed,
      )
      expect(set_trustedimage_project_policy.updateSafe).toStrictEqual(true)

      const trusted_users = getByName("trusted_users", parsed)
      expect(trusted_users.updateSafe).toStrictEqual(true)
    })

    it("does not matter if the annotation is there multiple times", () => {
      const parsed = parseVarsFile(DATA_SCIENCE_VARS)

      const container_image_tag = getByName("container_image_tag", parsed)
      expect(container_image_tag.updateSafe).toStrictEqual(true)
    })
  })

  describe("group variables", () => {
    it("group options", () => {
      const parsed = parseVarsFile(DATA_SCIENCE_VARS)
      const group = groupVariables(parsed)
      expect(group).not.toBeNull()
      expect(group).toHaveProperty(["0"])

      const billing_budget_alert_spent_percents = getByName(
        "billing_budget_alert_spent_percents",
        parsed,
      )
      expect(billing_budget_alert_spent_percents.group).not.toBeNull()
      expect(billing_budget_alert_spent_percents.group).toStrictEqual(0)
    })
  })
})
