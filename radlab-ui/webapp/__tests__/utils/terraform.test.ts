import {
  parseVarsFile,
  groupVariables,
  checkDependsOnValid,
  initialFormikData,
} from "@/utils/terraform"
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
    expect(billing_account_id.mandatory).toStrictEqual(true)
    expect(billing_account_id.required).toBe(true)

    const organization_id = getByName("organization_id", parsed)
    expect(organization_id.mandatory).toStrictEqual(false)
    expect(organization_id.required).toBe(false)

    const zone = getByName("zone", parsed)
    expect(zone.default).not.toBeNull()
    expect(zone.default).toStrictEqual("us-east4-c")
    expect(zone.mandatory).toStrictEqual(true)
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

  describe("depends on variables", () => {
    it("single vars depends on", () => {
      const parsed = parseVarsFile(DATA_SCIENCE_VARS)
      const varsAnswerData = initialFormikData(parsed)
      const create_container_image = getByName("create_container_image", parsed)
      expect(create_container_image.default).not.toBeNull()
      expect(create_container_image.default).toStrictEqual(true)

      const container_image_repository = getByName(
        "container_image_repository",
        parsed,
      )
      expect(container_image_repository).toHaveProperty("dependsOn")
      const isDependOnValid = checkDependsOnValid(
        container_image_repository.dependsOn,
        varsAnswerData,
      )
      expect(isDependOnValid).toBe(true)

      const enable_gpu_driver = getByName("enable_gpu_driver", parsed)
      expect(enable_gpu_driver.default).not.toBeNull()
      expect(enable_gpu_driver.default).toStrictEqual(false)

      const gpu_accelerator_type = getByName("gpu_accelerator_type", parsed)
      expect(gpu_accelerator_type).toHaveProperty("dependsOn")
      const isDependOnValidAcceleratorType = checkDependsOnValid(
        gpu_accelerator_type.dependsOn,
        varsAnswerData,
      )
      expect(isDependOnValidAcceleratorType).toBe(false)
    })

    it("multiple vars depends on AND operand", () => {
      const parsed = parseVarsFile(DATA_SCIENCE_VARS)
      const varsAnswerData = initialFormikData(parsed)
      const create_network = getByName("create_network", parsed)
      expect(create_network.default).not.toBeNull()
      expect(create_network.default).toStrictEqual(true)

      const create_usermanaged_notebook = getByName(
        "create_usermanaged_notebook",
        parsed,
      )
      expect(create_usermanaged_notebook.default).not.toBeNull()
      expect(create_usermanaged_notebook.default).toStrictEqual(true)

      const ip_cidr_range = getByName("ip_cidr_range", parsed)
      expect(ip_cidr_range).toHaveProperty("dependsOn")

      const isDependOnValid = checkDependsOnValid(
        ip_cidr_range.dependsOn,
        varsAnswerData,
      )
      expect(isDependOnValid).toBe(true)

      const enable_gpu_driver = getByName("enable_gpu_driver", parsed)
      expect(enable_gpu_driver.default).not.toBeNull()
      expect(enable_gpu_driver.default).toStrictEqual(false)

      const machine_type = getByName("machine_type", parsed)
      expect(machine_type).toHaveProperty("dependsOn")

      const isDependOnValidMachineType = checkDependsOnValid(
        machine_type.dependsOn,
        varsAnswerData,
      )
      expect(isDependOnValidMachineType).toBe(false)
    })

    it("multiple vars depends on OR operand", () => {
      const parsed = parseVarsFile(DATA_SCIENCE_VARS)
      const varsAnswerData = initialFormikData(parsed)
      const enable_gpu_driver = getByName("enable_gpu_driver", parsed)
      expect(enable_gpu_driver.default).not.toBeNull()
      expect(enable_gpu_driver.default).toStrictEqual(false)

      const create_usermanaged_notebook = getByName(
        "create_usermanaged_notebook",
        parsed,
      )
      expect(create_usermanaged_notebook.default).not.toBeNull()
      expect(create_usermanaged_notebook.default).toStrictEqual(true)

      const network_name = getByName("network_name", parsed)
      expect(network_name).toHaveProperty("dependsOn")

      const isDependOnValid = checkDependsOnValid(
        network_name.dependsOn,
        varsAnswerData,
      )
      expect(isDependOnValid).toBe(true)

      const set_external_ip_policy = getByName("set_external_ip_policy", parsed)
      expect(set_external_ip_policy.default).not.toBeNull()
      expect(set_external_ip_policy.default).toStrictEqual(false)

      const set_shielded_vm_policy = getByName("set_shielded_vm_policy", parsed)
      expect(set_shielded_vm_policy).toHaveProperty("dependsOn")

      const isDependOnValidVmPolicy = checkDependsOnValid(
        set_shielded_vm_policy.dependsOn,
        varsAnswerData,
      )
      expect(isDependOnValidVmPolicy).toBe(false)
    })

    it("multiple vars depends on OR and AND operand", () => {
      const parsed = parseVarsFile(DATA_SCIENCE_VARS)
      const varsAnswerData = initialFormikData(parsed)
      const enable_gpu_driver = getByName("enable_gpu_driver", parsed)
      expect(enable_gpu_driver.default).not.toBeNull()
      expect(enable_gpu_driver.default).toStrictEqual(false)

      const create_usermanaged_notebook = getByName(
        "create_usermanaged_notebook",
        parsed,
      )
      expect(create_usermanaged_notebook.default).not.toBeNull()
      expect(create_usermanaged_notebook.default).toStrictEqual(true)

      const create_network = getByName("create_network", parsed)
      expect(create_network.default).not.toBeNull()
      expect(create_network.default).toStrictEqual(true)

      const set_external_ip_policy = getByName("set_external_ip_policy", parsed)
      expect(set_external_ip_policy.default).not.toBeNull()
      expect(set_external_ip_policy.default).toStrictEqual(false)

      const subnet_name = getByName("subnet_name", parsed)
      expect(subnet_name).toHaveProperty("dependsOn")

      const isDependOnValid = checkDependsOnValid(
        subnet_name.dependsOn,
        varsAnswerData,
      )
      expect(isDependOnValid).toBe(true)

      const billing_budget_services = getByName(
        "billing_budget_services",
        parsed,
      )
      expect(billing_budget_services).toHaveProperty("dependsOn")

      const isDependOnValidBudgetService = checkDependsOnValid(
        billing_budget_services.dependsOn,
        varsAnswerData,
      )
      expect(isDependOnValidBudgetService).toBe(false)
    })
  })
})
