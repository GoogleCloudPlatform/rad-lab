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

const REGION_LIST: string[] = [
  "asia-east1",
  "asia-east2",
  "asia-northeast1",
  "asia-northeast2",
  "asia-northeast3",
  "asia-south1",
  "asia-south2",
  "asia-southeast1",
  "asia-southeast2",
  "australia-southeast1",
  "australia-southeast2",
  "europe-central2",
  "europe-north1",
  "europe-southwest1",
  "europe-west1",
  "europe-west2",
  "europe-west3",
  "europe-west4",
  "europe-west6",
  "europe-west8",
  "europe-west9",
  "northamerica-northeast1",
  "northamerica-northeast2",
  "southamerica-east1",
  "southamerica-west1",
  "us-central1",
  "us-east1",
  "us-east4",
  "us-east5",
  "us-south1",
  "us-west1",
  "us-west2",
  "us-west3",
  "us-west4",
]

export const ZONE_LIST: string[] = [
  "asia-east1-a",
  "asia-east1-b",
  "asia-east1-c",
  "asia-east2-a",
  "asia-east2-b",
  "asia-east2-c",
  "asia-northeast1-a",
  "asia-northeast1-b",
  "asia-northeast1-c",
  "asia-northeast2-a",
  "asia-northeast2-b",
  "asia-northeast2-c",
  "asia-northeast3-a",
  "asia-northeast3-b",
  "asia-northeast3-c",
  "asia-south1-a",
  "asia-south1-b",
  "asia-south1-c",
  "asia-south2-a",
  "asia-south2-b",
  "asia-south2-c",
  "asia-southeast1-a",
  "asia-southeast1-b",
  "asia-southeast1-c",
  "asia-southeast2-a",
  "asia-southeast2-b",
  "asia-southeast2-c",
  "australia-southeast1-a",
  "australia-southeast1-b",
  "australia-southeast1-c",
  "australia-southeast2-a",
  "australia-southeast2-b",
  "australia-southeast2-c",
  "europe-central2-a",
  "europe-central2-b",
  "europe-central2-c",
  "europe-north1-a",
  "europe-north1-b",
  "europe-north1-c",
  "europe-southwest1-a",
  "europe-southwest1-b",
  "europe-southwest1-c",
  "europe-west1-b",
  "europe-west1-c",
  "europe-west1-d",
  "europe-west2-a",
  "europe-west2-b",
  "europe-west2-c",
  "europe-west3-a",
  "europe-west3-b",
  "europe-west3-c",
  "europe-west4-a",
  "europe-west4-b",
  "europe-west4-c",
  "europe-west6-a",
  "europe-west6-b",
  "europe-west6-c",
  "europe-west8-a",
  "europe-west8-b",
  "europe-west8-c",
  "europe-west9-a",
  "europe-west9-b",
  "europe-west9-c",
  "northamerica-northeast1-a",
  "northamerica-northeast1-b",
  "northamerica-northeast1-c",
  "northamerica-northeast2-a",
  "northamerica-northeast2-b",
  "northamerica-northeast2-c",
  "southamerica-east1-a",
  "southamerica-east1-b",
  "southamerica-east1-c",
  "southamerica-west1-a",
  "southamerica-west1-b",
  "southamerica-west1-c",
  "us-central1-a",
  "us-central1-b",
  "us-central1-c",
  "us-central1-f",
  "us-east1-b",
  "us-east1-c",
  "us-east1-d",
  "us-east4-a",
  "us-east4-b",
  "us-east4-c",
  "us-east5-a",
  "us-east5-b",
  "us-east5-c",
  "us-south1-a",
  "us-south1-b",
  "us-south1-c",
  "us-west1-a",
  "us-west1-b",
  "us-west1-c",
  "us-west2-a",
  "us-west2-b",
  "us-west2-c",
  "us-west3-a",
  "us-west3-b",
  "us-west3-c",
  "us-west4-a",
  "us-west4-b",
  "us-west4-c",
]

export const DATA_DEFAULT_VARS = `

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

variable "region" {
  description = "Region where the resources should be created. {{UIMeta group=4 order=1 options=${REGION_LIST} }}"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Cloud Zone associated to the Vertex AI Workbench. {{UIMeta group=4 order=2 options=${ZONE_LIST} }}"
  type        = string
  default     = "us-central1-a"
}`
