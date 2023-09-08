// Write a unit test for a function that merges multiple objects together.

import { mergeAllSafe } from "@/utils/variables"

describe("mergeAllSafe", () => {
  it("should two objects together", () => {
    const adminVars = {
      organization_id: 123,
      folder_id: 456,
      billing_account_id: 789,
    }

    const moduleVars = {
      folder_id: 654,
      resource_creator_identity: "",
      billing_budget_alert_spent_percents: [0.5, 0.7, 1],
      create_budget: true,
      set_external_ip_policy: false,
      region: "us-central1",
      billing_budget_labels: { foo: "bar" },
    }

    const userVars = {
      resource_creator_identity: "",
      billing_budget_alert_spent_percents: [0.5, 0.7, 1],
      create_budget: false,
      region: "",
      billing_budget_labels: {},
    }

    const expected = {
      organization_id: 123,
      folder_id: 654,
      billing_account_id: 789,
      resource_creator_identity: "",
      billing_budget_alert_spent_percents: [0.5, 0.7, 1],
      create_budget: false,
      set_external_ip_policy: false,
      region: "us-central1",
      billing_budget_labels: { foo: "bar" },
    }

    const actual = mergeAllSafe([adminVars, moduleVars, userVars])

    expect(actual).toEqual(expected)
  })

  it("should merge objects with nested keys", () => {
    const adminVars = {
      foo: {
        bar: "baz",
      },
    }

    const moduleVars = {
      foo: {
        qux: "grault",
      },
    }

    const userVars = {}

    const expected = {
      foo: {
        bar: "baz",
        qux: "grault",
      },
    }

    const actual = mergeAllSafe([adminVars, moduleVars, userVars])

    expect(actual).toEqual(expected)
  })
})
