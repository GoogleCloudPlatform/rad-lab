/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {

  shielded_vm_policy = {
    set = {
      "constraints/compute.requireShieldedVm" = false
    }

    not_set = {}
  }

  external_ip_policy = {
    set = {
      "constraints/compute.vmExternalIpAccess" = {
        inherit_from_parent = null
        suggested_value     = null
        status              = true
        values              = null
      }
    }

    not_set = {}
  }

  trusted_image_project_policy = {
    set = {
      "constraints/compute.trustedImageProjects" = {
        inherit_from_parent = null
        suggested_value     = null
        status              = true
        values              = ["is:projects/deeplearning-platform-release"]
      }
    }

    not_set = {}
  }

  domain_restricted_sharing = {
    set = {
      "constraints/iam.allowedPolicyMemberDomains" = {
        inherit_from_parent = false
        suggested_value     = null
        status              = true
        values              = null
      }
    }
    not_set = {}
  }

  organization_bool_policies = merge(
    local.shielded_vm_policy[var.set_shielded_vm_policy ? "set" : "not_set"]
  )

  organization_list_policies = merge(
    local.external_ip_policy[var.set_external_ip_policy ? "set" : "not_set"],
    local.trusted_image_project_policy[var.set_trustedimage_project_policy ? "set" : "not_set"],
    #    local.domain_restricted_sharing[var.set_domain_restricted_sharing_policy && var.create_budget && var.billing_budget_pubsub_topic ? "set" : "not_set"]
    local.domain_restricted_sharing[var.set_domain_restricted_sharing_policy ? "set" : "not_set"]
  )

}