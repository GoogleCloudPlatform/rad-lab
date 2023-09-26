import {
  IModule,
  IHeader,
  SORT_DIRECTION,
  SORT_FIELD,
  ILogHeader,
  IBuildHeader,
  SORT_BUILD_FIELD,
} from "@/utils/types"

export const DEPLOYMENT_HEADERS: IHeader[] = [
  {
    label: "Module",
    field: SORT_FIELD.MODULE,
    direction: SORT_DIRECTION.ASC,
  },
  {
    label: "Deployment ID",
    field: SORT_FIELD.DEPLOYMENTID,
    direction: SORT_DIRECTION.ASC,
  },
  {
    label: "Project ID",
    field: SORT_FIELD.PROJECTID,
    direction: SORT_DIRECTION.ASC,
  },
  {
    label: "Email",
    field: SORT_FIELD.EMAIL,
    direction: SORT_DIRECTION.ASC,
  },
  {
    label: "CreatedAt",
    field: SORT_FIELD.CREATEDAT,
    direction: SORT_DIRECTION.ASC,
  },
  {
    label: "Status",
    field: SORT_FIELD.STATUS,
    direction: SORT_DIRECTION.ASC,
  },
]

export const BUILD_HEADER: IBuildHeader[] = [
  {
    label: "Build ID",
    field: SORT_BUILD_FIELD.BUILDID,
    direction: SORT_DIRECTION.ASC,
  },
  {
    label: "Action",
    field: SORT_BUILD_FIELD.ACTION,
    direction: SORT_DIRECTION.ASC,
  },
  {
    label: "Created At",
    field: SORT_BUILD_FIELD.CREATEDAT,
    direction: SORT_DIRECTION.ASC,
  },
  {
    label: "Email",
    field: SORT_BUILD_FIELD.EMAIL,
    direction: SORT_DIRECTION.ASC,
  },
]

export const LOGS_HEADERS: ILogHeader[] = [
  {
    header: "Generated LOGS",
  },
]

export const TEST_MODULES: IModule[] = [
  {
    name: "alpha_fold",
    projectId: "test-rad-lab",
    id: "xyz",
    variables: {},
    createdAt: {
      _seconds: 1658770787,
      _nanoseconds: 823000000,
    },
    updatedAt: {
      _seconds: 1658770787,
      _nanoseconds: 823000000,
    },
  },
  {
    name: "app_mod_elastic",
    projectId: "test-rad-lab",
    id: "xyz",
    variables: {},
    createdAt: {
      _seconds: 1658770787,
      _nanoseconds: 823000000,
    },
    updatedAt: {
      _seconds: 1658770787,
      _nanoseconds: 823000000,
    },
  },
  {
    name: "data_science",
    projectId: "test-rad-lab",
    id: "xyz",
    variables: {},
    createdAt: {
      _seconds: 1658770787,
      _nanoseconds: 823000000,
    },
    updatedAt: {
      _seconds: 1658770787,
      _nanoseconds: 823000000,
    },
  },
  {
    name: "genomics_cromwell",
    projectId: "test-rad-lab",
    id: "xyz",
    variables: {},
    createdAt: {
      _seconds: 1658770787,
      _nanoseconds: 823000000,
    },
    updatedAt: {
      _seconds: 1658770787,
      _nanoseconds: 823000000,
    },
  },
  {
    name: "genomics_dsub",
    projectId: "test-rad-lab",
    id: "xyz",
    variables: {},
    createdAt: {
      _seconds: 1658770787,
      _nanoseconds: 823000000,
    },
    updatedAt: {
      _seconds: 1658770787,
      _nanoseconds: 823000000,
    },
  },
  {
    name: "silicon_design",
    projectId: "test-rad-lab",
    id: "xyz",
    variables: {},
    createdAt: {
      _seconds: 1658770787,
      _nanoseconds: 823000000,
    },
    updatedAt: {
      _seconds: 1658770787,
      _nanoseconds: 823000000,
    },
  },
]

export const DATA_SCIENCE_VARS = `

variable "billing_account_id" {
  description = "Billing Account associated to the GCP Resources {{UIMeta group=0 order=3 }}"
  type        = string
}

variable "boot_disk_size_gb" {
  description = "The size of the boot disk in GB attached to this instance {{UIMeta group=3 order=7 options=50,100,500 }}"
  type        = number
  default     = 100
}

variable "boot_disk_type" {
  description = "Disk types for notebook instances {{UIMeta group=3 order=6 }}"
  type        = string
  default     = "PD_SSD"
}

variable "create_container_image" {
  description = "If the notebook needs to have image type as Container set this variable to true, set it to false when using dafault image type i.e. VM. {{UIMeta group=3 order=2 }}"
  type        = bool
  default     = false
}

variable "create_network" {
  description = "If the module has to be deployed in an existing network, set this variable to false. {{UIMeta group=2 order=1 }}"
  type        = bool
  default     = true
}

variable "create_project" {
  description = "Set to true if the module has to create a project.  If you want to deploy in an existing project, set this variable to false. {{UIMeta group=1 order=1 }}"
  type        = bool
  default     = true
}

variable "container_image_repository" {
  description = "Container Image Repo, only set if creating container image notebook instance by setting \`create_container_image\` variable to true {{UIMeta group=3 order=3 }}"
  type        = string
  default     = ""
}

variable "container_image_tag" {
  description = "Container Image Tag, only set if creating container image notebook instance by setting \`create_container_image\` variable to true {{UIMeta group=3 order=4 }}"
  type        = string
  default     = "latest"
}

variable "enable_gpu_driver" {
  description = "Install GPU driver on the instance {{UIMeta group=3 order=8 }}"
  type        = bool
  default     = false
}

variable "enable_services" {
  description = "Enable the necessary APIs on the project.  When using an existing project, this can be set to false. {{UIMeta group=1 order=3 }}"
  type        = bool
  default     = true
}

variable "folder_id" {
  description = "Folder ID where the project should be created. It can be skipped if already setting organization_id. Leave blank if the project should be created directly underneath the Organization node. {{UIMeta group=0 order=2 }}"
  type        = string
  default     = ""
}

variable "gpu_accelerator_type" {
  description = "Type of GPU you would like to spin up {{UIMeta group=3 order=9 }}"
  type        = string
  default     = ""
}

variable "gpu_accelerator_core_count" {
  description = "Number of of GPU core count {{UIMeta group=3 order=10 }}"
  type        = number
  default     = null
}

variable "image_family" {
  description = "Image of the AI notebook. {{UIMeta group=3 order=12 }}"
  type        = string
  default     = "tf-latest-cpu"
}

variable "image_project" {
  description = "Google Cloud project where the image is hosted. {{UIMeta group=3 order=11 }}"
  type        = string
  default     = "deeplearning-platform-release"
}

variable "ip_cidr_range" {
  description = "Unique IP CIDR Range for AI Notebooks subnet {{UIMeta group=2 order=5 }}"
  type        = string
  default     = "10.142.190.0/24"
}

variable "machine_type" {
  description = "Type of VM you would like to spin up {{UIMeta group=3 order=5 }}"
  type        = string
  default     = "n1-standard-1"
}

variable "network_name" {
  description = "Name of the network to be created. {{UIMeta group=2 order=2 }}"
  type        = string
  default     = "ai-notebook"
}

variable "notebook_count" {
  description = "Number of AI Notebooks requested {{UIMeta group=3 order=1 }}"
  type        = string
  default     = "1"
}

variable "organization_id" {
  description = "Organization ID where GCP Resources need to get spin up. It can be skipped if already setting folder_id {{UIMeta group=0 order=1 }}"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Project name or ID, if it's an existing project. {{UIMeta group=1 order=2 }}"
  type        = string
  default     = "radlab-data-science"
}

variable "random_id" {
  description = "Adds a suffix of 4 random characters to the \`project_id\` {{UIMeta group=0 }}"
  type        = string
  default     = null
}

variable "set_external_ip_policy" {
  description = "Enable org policy to allow External (Public) IP addresses on virtual machines. {{UIMeta group=0 }}"
  type        = bool
  default     = true
}

variable "set_shielded_vm_policy" {
  description = "Apply org policy to disable shielded VMs. {{UIMeta group=0 }}"
  type        = bool
  default     = true
}

variable "set_trustedimage_project_policy" {
  description = "Apply org policy to set the trusted image projects. {{UIMeta group=0 }}"
  type        = bool
  default     = true
}

variable "subnet_name" {
  description = "Name of the subnet where to deploy the Notebooks. {{UIMeta group=2 order=4 }}"
  type        = string
  default     = "subnet-ai-notebook"
}

variable "trusted_users" {
  description = "The list of trusted users. {{UIMeta group=1 order=4 }}"
  type        = set(string)
  default     = []
}

variable "zone" {
  description = "Cloud Zone associated to the AI Notebooks {{UIMeta group=2 order=3 options=us-central1-b,us-east1-a,us-west3-b,us-east4-c }}"
  type        = string
  default     = "us-east4-c"
}
`
export const SILICON_DESIGN_VARS = `variable "billing_account_id" {
  description = "Billing Account associated to the GCP Resources"
  type        = string
}

variable "boot_disk_size_gb" {
  description = "The size of the boot disk in GB attached to this instance"
  type        = number
  default     = 100
}

variable "boot_disk_type" {
  description = "Disk types for notebook instances"
  type        = string
  default     = "PD_SSD"
}

variable "create_network" {
  description = "If the module has to be deployed in an existing network, set this variable to false."
  type        = bool
  default     = true
}

variable "create_project" {
  description = "Set to true if the module has to create a project.  If you want to deploy in an existing project, set this variable to false."
  type        = bool
  default     = true
}

variable "enable_services" {
  description = "Enable the necessary APIs on the project.  When using an existing project, this can be set to false."
  type        = bool
  default     = true
}

variable "folder_id" {
  description = "Folder ID where the project should be created. It can be skipped if already setting organization_id. Leave blank if the project should be created directly underneath the Organization node. "
  type        = string
  default     = ""
}

variable "ip_cidr_range" {
  description = "Unique IP CIDR Range for AI Notebooks subnet"
  type        = string
  default     = "10.142.190.0/24"
}

variable "machine_type" {
  description = "Type of VM you would like to spin up"
  type        = string
  default     = "n1-standard-1"
}

variable "network_name" {
  description = "Name of the network to be created."
  type        = string
  default     = "ai-notebook"
}

variable "notebook_count" {
  description = "Number of AI Notebooks requested"
  type        = number
  default     = 1
}

variable "notebook_names" {
  description = "Names of AI Notebooks requested"
  type        = list(string)
  default     = []
}

variable "organization_id" {
  description = "Organization ID where GCP Resources need to get spin up. It can be skipped if already setting folder_id"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Project name or ID, if it's an existing project."
  type        = string
  default     = "radlab-silicon-design"
}
variable "random_id" {
  description = "Adds a suffix of 4 random characters to the \`project_id\`"
  type        = string
  default     = null
}

variable "set_external_ip_policy" {
  description = "Enable org policy to allow External (Public) IP addresses on virtual machines."
  type        = bool
  default     = true
}

variable "set_shielded_vm_policy" {
  description = "Apply org policy to disable shielded VMs."
  type        = bool
  default     = true
}

variable "set_trustedimage_project_policy" {
  description = "Apply org policy to set the trusted image projects."
  type        = bool
  default     = true
}

variable "subnet_name" {
  description = "Name of the subnet where to deploy the Notebooks."
  type        = string
  default     = "subnet-ai-notebook"
}

variable "trusted_users" {
  description = "The list of trusted users."
  type        = set(string)
  default     = []
}

variable "zone" {
  description = "Cloud Zone associated to the AI Notebooks"
  type        = string
  default     = "us-east4-c"
}`
export const GENOMICS_CHROMWELL_VARS = `
variable "billing_account_id" {
  description = "Billing Account associated to the GCP Resources"
  type        = string
}
variable "create_network" {
  description = "If the module has to be deployed in an existing network, set this variable to false."
  type        = bool
  default     = true
}

variable "create_project" {
  description = "Set to true if the module has to create a project.  If you want to deploy in an existing project, set this variable to false."
  type        = bool
  default     = true
}
variable "cromwell_db_name" {
  description = "The name of the SQL Database instance"
  default     = "cromwelldb"
}

variable "cromwell_db_tier" {
  description = "CloudSQL tier, please refere to the documentation at https://cloud.google.com/sql/docs/mysql/instance-settings#machine-type-2ndgen ."
  type        = string
  default     = "db-n1-standard-2"

}
variable "cromwell_PAPI_endpoint" {
  description = "Endpoint for Life Sciences APIs. For locations other than us-central1, the endpoint needs to be updated to match the location For example for \"europe-west4\" location the endpoint-url should be \"https://europe-west4-lifesciences.googleapi/\""
  type        = string
  default     = "https://lifesciences.googleapis.com"
}
variable "cromwell_PAPI_location" {
  description = "Google Cloud region or multi-region where the Life Sciences API endpoint will be used. This does not affect where worker instances or data will be stored."
  type        = string
  default     = "us-central1"
}
variable "cromwell_port" {
  description = "Port Cromwell server will use for the REST API and web user interface."
  type        = string
  default     = "8000"
}
variable "cromwell_sa_roles" {
  description = "List of roles granted to the cromwell service account. This server account will be used to run both the Cromwell server and workers as well."
  type        = list(any)
  default = [
    "roles/lifesciences.workflowsRunner",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/storage.objectAdmin",
    "roles/cloudsql.client",
    "roles/browser"
  ]
}

variable "cromwell_server_instance_name" {
  description = "Name of the VM instance that will be used to deploy Cromwell Server, this should be a valid Google Cloud instance name."
  type        = string
  default     = "cromwell-server"
}
variable "cromwell_server_instance_type" {
  description = "Cromwell server instance type"
  type        = string
  default     = "e2-standard-4"
}
variable "cromwell_version" {
  description = "Cromwell version that will be downloaded, for the latest release version, please check https://github.com/broadinstitute/cromwell/releases for the latest releases."
  type        = string
  default     = "72"

}


variable "cromwell_zones" {
  description = "GCP Zones that will be set as the default runtime in Cromwell config file."
  type        = list(any)
  default     = ["us-central1-a", "us-central1-b"]
}
variable "db_service_network_cidr_range" {
  description = "CIDR range used for the private service range for CloudSQL"
  type        = string
  default     = "10.128.50.0/24"
}

variable "default_region" {
  description = "The default region where the CloudSQL, Compute Instance and VPCs will be deployed"
  type        = string
  default     = "us-central1"
}
variable "default_zone" {
  description = "The default zone where the CloudSQL, Compute Instance be deployed"
  type        = string
  default     = "us-central1-a"
}
variable "enable_services" {
  description = "Enable the necessary APIs on the project.  When using an existing project, this can be set to false."
  type        = bool
  default     = true
}

variable "folder_id" {
  description = "Folder ID where the project should be created. It can be skipped if already setting organization_id. Leave blank if the project should be created directly underneath the Organization node. "
  type        = string
  default     = ""
}
variable "ip_cidr_range" {
  description = "Unique IP CIDR Range for cromwell subnet"
  type        = string
  default     = "10.142.190.0/24"
}

variable "network_name" {
  description = "This name will be used for VPC and subnets created"
  type        = string
  default     = "cromwell-vpc"
}

variable "organization_id" {
  description = "Organization ID where GCP Resources need to get spin up. It can be skipped if already setting folder_id"
  type        = string
  default     = ""
}
variable "project_name" {
  description = "Project name or ID, if it's an existing project."
  type        = string
  default     = "radlab-genomics-cromwell"
}

variable "random_id" {
  description = "Adds a suffix of 4 random characters to the \`project_id\`"
  type        = string
  default     = null
}

variable "set_external_ip_policy" {
  description = "If true external IP Policy will be set to allow all"
  type        = bool
  default     = false
}

variable "set_restrict_vpc_peering_policy" {
  description = "If true restrict VPC peering will be set to allow all"
  type        = bool
  default     = true
}

variable "set_shielded_vm_policy" {
  description = "If true shielded VM Policy will be set to disabled"
  type        = bool
  default     = true
}

variable "set_trustedimage_project_policy" {
  description = "If true trusted image projects will be set to allow all"
  type        = bool
  default     = true
}
`

export const DATA_SCIENCE_MAIN = `/**
* Copyright 2023 Google LLC
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
 random_id = var.random_id != null ? var.random_id : random_id.default.hex
 project = (var.create_project
   ? try(module.project_radlab_ds_analytics.0, null)
   : try(data.google_project.existing_project.0, null)
 )
 region = join("-", [split("-", var.zone)[0], split("-", var.zone)[1]])

 network = (
   var.create_network
   ? try(module.vpc_ai_notebook.0.network.network, null)
   : try(data.google_compute_network.default.0, null)
 )

 subnet = (
   var.create_network
   ? try(module.vpc_ai_notebook.0.subnets["\${local.region}/\${var.subnet_name}"], null)
   : try(data.google_compute_subnetwork.default.0, null)
 )

 notebook_sa_project_roles = [
   "roles/compute.instanceAdmin",
   "roles/notebooks.admin",
   "roles/bigquery.user",
   "roles/storage.objectViewer",
   "roles/iam.serviceAccountUser"
 ]

 project_services = var.enable_services ? [
   "compute.googleapis.com",
   "bigquery.googleapis.com",
   "notebooks.googleapis.com",
   "bigquerystorage.googleapis.com"
 ] : []
}

resource "random_id" "default" {
 byte_length = 2
}

#####################
# ANALYTICS PROJECT #
#####################

data "google_project" "existing_project" {
 count      = var.create_project ? 0 : 1
 project_id = var.project_name
}

module "project_radlab_ds_analytics" {
 count   = var.create_project ? 1 : 0
 source  = "terraform-google-modules/project-factory/google"
 version = "~> 11.0"

 name              = format("%s-%s", var.project_name, local.random_id)
 random_project_id = false
 folder_id         = var.folder_id
 billing_account   = var.billing_account_id
 org_id            = var.organization_id

 activate_apis = []
}

resource "google_project_service" "enabled_services" {
 for_each                   = toset(local.project_services)
 project                    = local.project.project_id
 service                    = each.value
 disable_dependent_services = true
 disable_on_destroy         = true

 depends_on = [
   module.project_radlab_ds_analytics
 ]
}

data "google_compute_network" "default" {
 count   = var.create_network ? 0 : 1
 project = local.project.project_id
 name    = var.network_name
}

data "google_compute_subnetwork" "default" {
 count   = var.create_network ? 0 : 1
 project = local.project.project_id
 name    = var.subnet_name
 region  = local.region
}

module "vpc_ai_notebook" {
 count   = var.create_network ? 1 : 0
 source  = "terraform-google-modules/network/google"
 version = "~> 3.0"

 project_id   = local.project.project_id
 network_name = var.network_name
 routing_mode = "GLOBAL"
 description  = "VPC Network created via Terraform"

 subnets = [
   {
     subnet_name           = var.subnet_name
     subnet_ip             = var.ip_cidr_range
     subnet_region         = local.region
     description           = "Subnetwork inside *vpc-analytics* VPC network, created via Terraform"
     subnet_private_access = true
   }
 ]

 firewall_rules = [
   {
     name        = "fw-ai-notebook-allow-internal"
     description = "Firewall rule to allow traffic on all ports inside *vpc-analytics* VPC network."
     priority    = 65534
     ranges      = ["10.0.0.0/8"]
     direction   = "INGRESS"

     allow = [{
       protocol = "tcp"
       ports    = ["0-65535"]
     }]
   }
 ]

 depends_on = [
   google_project_service.enabled_services
 ]
}

resource "google_service_account" "sa_p_notebook" {
 project      = local.project.project_id
 account_id   = format("sa-p-notebook-%s", local.random_id)
 display_name = "Notebooks in trusted environment"
}

resource "google_project_iam_member" "sa_p_notebook_permissions" {
 for_each = toset(local.notebook_sa_project_roles)
 project  = local.project.project_id
 member   = "serviceAccount:\${google_service_account.sa_p_notebook.email}"
 role     = each.value
}

resource "google_service_account_iam_member" "sa_ai_notebook_user_iam" {
 for_each           = var.trusted_users
 member             = each.value
 role               = "roles/iam.serviceAccountUser"
 service_account_id = google_service_account.sa_p_notebook.id
}

resource "google_project_iam_member" "ai_notebook_user_role1" {
 for_each = var.trusted_users
 project  = local.project.project_id
 member   = each.value
 role     = "roles/notebooks.admin"
}

resource "google_project_iam_member" "ai_notebook_user_role2" {
 for_each = var.trusted_users
 project  = local.project.project_id
 member   = each.value
 role     = "roles/viewer"
}

resource "google_notebooks_instance" "ai_notebook" {
 count        = var.notebook_count
 project      = local.project.project_id
 name         = "notebooks-instance-\${count.index}"
 location     = var.zone
 machine_type = var.machine_type

 dynamic "vm_image" {
   for_each = var.create_container_image ? [] : [1]
   content {
     project      = var.image_project
     image_family = var.image_family
   }
 }

 dynamic "container_image" {
   for_each = var.create_container_image ? [1] : []
   content {
     repository = var.container_image_repository
     tag = var.container_image_tag
   }
 }

 install_gpu_driver = var.enable_gpu_driver

 dynamic "accelerator_config"{
   for_each = var.enable_gpu_driver ? [1] : []
   content {
     type         = var.gpu_accelerator_type
     core_count   = var.gpu_accelerator_core_count
   }
 }

 service_account = google_service_account.sa_p_notebook.email

 boot_disk_type     = var.boot_disk_type
 boot_disk_size_gb  = var.boot_disk_size_gb

 no_public_ip    = false
 no_proxy_access = false

 network = local.network.self_link
 subnet  = local.subnet.self_link

 post_startup_script = format("gs://%s/%s", google_storage_bucket.user_scripts_bucket.name,google_storage_bucket_object.notebook_post_startup_script.name)

 labels = {
   module = "data-science"
 }

 metadata = {
   terraform  = "true"
   proxy-mode = "mail"
 }
 depends_on = [
   time_sleep.wait_120_seconds,
   google_storage_bucket_object.notebooks
   ]
}

resource "google_storage_bucket" "user_scripts_bucket" {
 project                     = local.project.project_id
 name                        = join("", ["user-scripts-", local.project.project_id])
 location                    = "US"
 force_destroy               = true
 uniform_bucket_level_access = true

 cors {
   origin          = ["http://user-scripts"]
   method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
   response_header = ["*"]
   max_age_seconds = 3600
 }
}

resource "google_storage_bucket_iam_binding" "binding" {
 bucket  = google_storage_bucket.user_scripts_bucket.name
 role    = "roles/storage.admin"
 members = var.trusted_users
}
`

export const DEFAULT_ADMIN_VARS = `

variable "billing_account_id" {
  description = "Billing Account associated to the GCP Resources. {{UIMeta group=1 order=1 }}"
  type        = string
}

variable "organization_id" {
  description = "Organization ID where GCP Resources need to get spin up. It can be skipped if already setting folder_id. {{UIMeta group=2 order=1 }}"
  type        = string
  default     = ""
}

variable "folder_id" {
  description = "Folder ID where the project should be created. {{UIMeta group=3 order=1 }}"
  type        = string
  default     = ""
}

variable "email_notifications" {
  description = "Enable email notifications to Trusted and Owner Users/Groups for RAD Lab deployment events. {{UIMeta group=4 order=1 }}"
  type        = bool
  default     = false
}
variable "mail_server_email" {
  description = "Gmail address for sending email notifications. {{UIMeta group=4 order=2 }}"
  type        = string
  default     = ""
}
variable "mail_server_password" {
  description = "Gmail password (see more at https://googlecloudplatform.github.io/rad-lab/docs/rad-lab-ui/troubleshooting). {{UIMeta group=4 order=3 }}"
  type        = string
  default     = ""
}
`

export const EXAMPLE_CLOUD_BUILD_LOGS = `
starting build "12345678-eeee-4c4c-a94f-abdf234223425"

FETCHSOURCE
Initialized empty Git repository in /workspace/.git/
From https://github.com/[REPO]/rad-lab
 * branch            [HASH] -> FETCH_HEAD
HEAD is now at [HASH] Disallow scroll wheel to change number inputs
BUILD
Starting Step #0 - "Download TFVARS content"
Step #0 - "Download TFVARS content": Already have image (with digest): gcr.io/cloud-builders/git
Step #0 - "Download TFVARS content": Copying gs://rad-lab-deployments/deployments/data_science_####/files/terraform.tfvars.json...
Step #0 - "Download TFVARS content": / [0 files][    0.0 B/  1.7 KiB]
/ [1 files][  1.7 KiB/  1.7 KiB]
Step #0 - "Download TFVARS content": Operation completed over 1 objects/1.7 KiB.
Step #0 - "Download TFVARS content": Copying gs://rad-lab-deployments/deployments/data_science_####/files/backend.tf...
Step #0 - "Download TFVARS content": / [0 files][    0.0 B/  147.0 B]
/ [1 files][  147.0 B/  147.0 B]
Step #0 - "Download TFVARS content": Operation completed over 1 objects/147.0 B.
Finished Step #0 - "Download TFVARS content"
Starting Step #1 - "Init"
Step #1 - "Init": Pulling image: us-central1-docker.pkg.dev/PROJECT_ID/PROJECT_ID-registry/terraform
Step #1 - "Init": Using default tag: latest
Step #1 - "Init": latest: Pulling from PROJECT_ID/PROJECT_ID-registry/terraform
Step #1 - "Init": Status: Downloaded newer image for us-central1-docker.pkg.dev/PROJECT_ID/PROJECT_ID-registry/terraform:latest
Step #1 - "Init": us-central1-docker.pkg.dev/PROJECT_ID/PROJECT_ID-registry/terraform:latest
Step #1 - "Init": Running terraform init -reconfigure -upgrade ...
Step #1 - "Init": [0m[1mUpgrading modules...[0m
Step #1 - "Init": Downloading registry.terraform.io/terraform-google-modules/network/google 5.2.0 for vpc_ai_notebook...
Step #1 - "Init": - vpc_ai_notebook in .terraform/modules/vpc_ai_notebook
Step #1 - "Init": - vpc_ai_notebook.firewall_rules in .terraform/modules/vpc_ai_notebook/modules/firewall-rules
Step #1 - "Init": - vpc_ai_notebook.routes in .terraform/modules/vpc_ai_notebook/modules/routes
Step #1 - "Init": - vpc_ai_notebook.subnets in .terraform/modules/vpc_ai_notebook/modules/subnets
Step #1 - "Init": - vpc_ai_notebook.vpc in .terraform/modules/vpc_ai_notebook/modules/vpc
Step #1 - "Init":
Step #1 - "Init": [0m[1mInitializing the backend...[0m
Step #1 - "Init": [0m[32m
Step #1 - "Init": Successfully configured the backend "gcs"! Terraform will automatically
Step #1 - "Init": use this backend unless the backend configuration changes.[0m
Step #1 - "Init":
Step #1 - "Init": [0m[1mInitializing provider plugins...[0m
Step #1 - "Init": - Finding hashicorp/google-beta versions matching ">= 3.43.0, >= 3.45.0, >= 3.50.0, ~> 4.0, ~> 4.11, < 5.0.0"...
Step #1 - "Init": - Finding hashicorp/google versions matching ">= 2.12.0, >= 3.43.0, >= 3.45.0, >= 3.50.0, >= 3.83.0, ~> 4.0, ~> 4.5, ~> 4.11, < 5.0.0"...
Step #1 - "Init": - Finding latest version of hashicorp/time...
Step #1 - "Init": - Finding hashicorp/null versions matching ">= 2.1.0"...
Step #1 - "Init": - Finding hashicorp/random versions matching ">= 2.2.0"...
Step #1 - "Init": - Installing hashicorp/time v0.9.1...
Step #1 - "Init": - Installed hashicorp/time v0.9.1 (signed by HashiCorp)
Step #1 - "Init": - Installing hashicorp/null v3.2.1...
Step #1 - "Init": - Installed hashicorp/null v3.2.1 (signed by HashiCorp)
Step #1 - "Init": - Installing hashicorp/random v3.5.1...
Step #1 - "Init": - Installed hashicorp/random v3.5.1 (signed by HashiCorp)
Step #1 - "Init": - Installing hashicorp/google-beta v4.80.0...
Step #1 - "Init": - Installed hashicorp/google-beta v4.80.0 (signed by HashiCorp)
Step #1 - "Init": - Installing hashicorp/google v4.80.0...
Step #1 - "Init": - Installed hashicorp/google v4.80.0 (signed by HashiCorp)
Step #1 - "Init":
Step #1 - "Init": Terraform has created a lock file [1m.terraform.lock.hcl[0m to record the provider
Step #1 - "Init": selections it made above. Include this file in your version control repository
Step #1 - "Init": so that Terraform can guarantee to make the same selections by default when
Step #1 - "Init": you run "terraform init" in the future.[0m
Step #1 - "Init":
Step #1 - "Init": [0m[1m[32mTerraform has been successfully initialized![0m[32m[0m
Step #1 - "Init": [0m[32m
Step #1 - "Init": You may now begin working with Terraform. Try running "terraform plan" to see
Step #1 - "Init": any changes that are required for your infrastructure. All Terraform commands
Step #1 - "Init": should now work.
Step #1 - "Init":
Step #1 - "Init": If you ever set or change modules or backend configuration for Terraform,
Step #1 - "Init": rerun this command to reinitialize your working directory. If you forget, other
Step #1 - "Init": commands will detect it and remind you to do so if necessary.[0m
Finished Step #1 - "Init"
Starting Step #2 - "Apply"
Step #2 - "Apply": Already have image (with digest): us-central1-docker.pkg.dev/PROJECT_ID/PROJECT_ID-registry/terraform
Step #2 - "Apply":
Step #2 - "Apply": Terraform used the selected providers to generate the following execution
Step #2 - "Apply": plan. Resource actions are indicated with the following symbols:
Step #2 - "Apply":   [32m+[0m create
Step #2 - "Apply":  [36m<=[0m read (data resources)
Step #2 - "Apply": [0m
Step #2 - "Apply": Terraform will perform the following actions:
Step #2 - "Apply": Names of resources
Step #2 - "Apply": .....
Step #2 - "Apply": Apply complete! Resources: 30 added, 0 changed, 0 destroyed.
Step #2 - "Apply": [0m[0m[1m[32m
Step #2 - "Apply": Outputs:
Step #2 - "Apply":
Step #2 - "Apply": [0mbilling_budget_budget_id = <sensitive>
Step #2 - "Apply": deployment_id = "####"
Step #2 - "Apply": notebooks_googlemanaged_names = ""
Step #2 - "Apply": notebooks_googlemanaged_urls = tolist([])
Step #2 - "Apply": notebooks_usermanaged_names = [
Step #2 - "Apply":   "usermanaged-notebooks-1",
Step #2 - "Apply": ]
Step #2 - "Apply": notebooks_usermanaged_urls = tolist([
Step #2 - "Apply":   "https://",
Step #2 - "Apply": ])
Step #2 - "Apply": project_id = "$PROJECT_ID"
Step #2 - "Apply": user_scripts_bucket_uri = "https://www.googleapis.com/storage/v1/b/bucket-here"
Finished Step #2 - "Apply"
Starting Step #3 - "Refresh"
Step #3 - "Refresh": RuAlready have image (with digest): us-central1-docker.pkg.dev/PROJECT_ID/PROJECT_ID-registry/terraform
Step #3 - "Refresh": Running terraform apply -refresh-only -auto-approve ...
Step #3 - "Refresh": [0m[1mmodule.project_radlab_ds_analytics[0].module.project-factory.random_id.random_project_id_suffix: Refreshing state... [id=rtQ][0m
Step #3 - "Refresh": [0m[1mmodule.project_radlab_ds_analytics[0].module.project-factory.google_project.main: Refreshing state... [id=projects/radlab-data-science][0m
Step #3 - "Refresh": [0m[1mmodule.project_radlab_ds_analytics[0].module.project-factory.google_service_account.default_service_account[0]: Refreshing state... [id=projects/radlab-data-science/serviceAccounts/project-service-account@radlab-data-science.iam.gserviceaccount.com][0m
Step #3 - "Refresh": [0m[1mmodule.project_radlab_ds_analytics[0].module.project-factory.google_project_default_service_accounts.default_service_accounts[0]: Refreshing state... [id=projects/radlab-data-science][0m
Step #3 - "Refresh": [0m[1mmodule.project_radlab_ds_analytics[0].module.budget.data.google_project.project[0]: Reading...[0m[0m
Step #3 - "Refresh": [0m[1mmodule.project_radlab_ds_analytics[0].module.budget.data.google_project.project[0]: Read complete after 0s [id=projects/radlab-data-science][0m
Step #3 - "Refresh": [0m[1mgoogle_project_service.enabled_services["notebooks.googleapis.com"]: Refreshing state... [id=radlab-data-science/notebooks.googleapis.com][0m
Step #3 - "Refresh": [0m[1mgoogle_project_service.enabled_services["compute.googleapis.com"]: Refreshing state... [id=radlab-data-science/compute.googleapis.com][0m
Step #3 - "Refresh": [0m[1mgoogle_project_iam_member.role_notebooks_admin["user:user@example.com"]: Refreshing state... [id=radlab-data-science/roles/notebooks.admin/user:user@example.com][0m
Step #3 - "Refresh": [0m[1mgoogle_service_account.sa_p_notebook: Refreshing state... [id=projects/radlab-data-science/serviceAccounts/sa-p-notebook@radlab-data-science.iam.gserviceaccount.com][0m
Step #3 - "Refresh": [0m[1mgoogle_project_iam_member.role_viewer["user:user@example.com"]: Refreshing state... [id=radlab-data-science/roles/viewer/user:user@example.com][0m
Step #3 - "Refresh": [0m[1mgoogle_project_service.enabled_services["bigquery.googleapis.com"]: Refreshing state... [id=radlab-data-science/bigquery.googleapis.com][0m
Finished Step #3 - "Refresh"
Starting Step #4 - "Output"
Step #4 - "Output": Already have image (with digest): us-central1-docker.pkg.dev/PROJECT_ID/PROJECT_ID-registry/terraform
Step #4 - "Output": Copying file://output.json [Content-Type=application/json]...
Step #4 - "Output": / [0/1 files][    0.0 B/  1.1 KiB]   0% Done
/ [1/1 files][  1.1 KiB/  1.1 KiB] 100% Done
Step #4 - "Output": Operation completed over 1 objects/1.1 KiB.
Finished Step #4 - "Output"
Starting Step #5 - "Upload Files"
Step #5 - "Upload Files": Already have image (with digest): gcr.io/cloud-builders/gsutil
Step #5 - "Upload Files": Copying file://data_science.tar.gz [Content-Type=application/x-tar]...
Step #5 - "Upload Files": / [0/1 files][    0.0 B/ 65.2 MiB]   0% Done
-
- [0/1 files][ 64.2 MiB/ 65.2 MiB]  98% Done
- [1/1 files][ 65.2 MiB/ 65.2 MiB] 100% Done
Step #5 - "Upload Files": Operation completed over 1 objects/65.2 MiB.
Finished Step #5 - "Upload Files"
PUSH
DONE
`
