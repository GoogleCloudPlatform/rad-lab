export const DATA_SCIENCE_VARS = `

# {{UIMeta group=1 order=1 }}
variable "billing_account_id" {
  description = "Billing Account associated to the GCP Resources. {{UIMeta group=0 order=3 mandatory }}"
  type        = string
}

variable "boot_disk_size_gb" {
  description = "The size of the boot disk in GB attached to this instance {{UIMeta group=2 order=2 options=50,100,500 }}"
  type        = number
  default     = 100
}

variable "boot_disk_type" {
  description = "Disk types for notebook instances"
  type        = string
  default     = "PD_SSD"
}

variable "create_container_image" {
  description = "If the notebook needs to have image type as Container set this variable to true, set it to false when using dafault image type i.e. VM."
  type        = bool
  default     = true
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

variable "create_usermanaged_notebook" {
  description = "Set to true if you want to create user managed workbench notebooks. If you want to create google managed workbench notebook, set this variable to false. {{UIMeta group=2 order=1 }}"
  type        = bool
  default     = true
}

variable "container_image_repository" {
  description = "Container Image Repo, only set if creating container image notebook instance by setting \`create_container_image\` variable to true. {{UIMeta group=2 order=4 dependson=(create_container_image==true) mandatory }}"
  type        = string
  default     = ""
}

variable "container_image_tag" {
  description = "Container Image Tag, only set if creating container image notebook instance by setting \`create_container_image\` variable to true {{UIMeta updatesafe updatesafe updatesafe}}"
  type        = string
  default     = "latest"
}

variable "enable_gpu_driver" {
  description = "Install GPU driver on the instance {{UIMeta order=20 group=11}}"
  type        = bool
  default     = false
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

variable "gpu_accelerator_type" {
  description = "Type of GPU you would like to spin up. {{UIMeta group=2 order=10 dependson=(enable_gpu_driver==true) mandatory }}"
  type        = string
  default     = ""
}

variable "gpu_accelerator_core_count" {
  description = "Number of of GPU core count"
  type        = number
  default     = null
}

variable "image_family" {
  description = "Image of the AI notebook."
  type        = string
  default     = "tf-latest-cpu"
}

variable "image_project" {
  description = "Google Cloud project where the image is hosted."
  type        = string
  default     = "deeplearning-platform-release"
}

variable "ip_cidr_range" {
  description = "Unique IP CIDR Range for AI Notebooks subnet {{UIMeta group=3 order=5 dependson=(create_network==true&&create_usermanaged_notebook==true) mandatory}}"
  type        = string
  default     = "10.142.190.0/24"
}

variable "machine_type" {
  description = "Type of VM you would like to spin up.{{UIMeta group=3 order=5 dependson=(create_network==true&&enable_gpu_driver==true)}}"
  type        = string
  default     = "n1-standard-1"
}

variable "network_name" {
  description = "Name of the network to be created. {{UIMeta group=3 order=2 dependson=(create_usermanaged_notebook==true||enable_gpu_driver==true) mandatory}}"
  type        = string
  default     = "ai-notebook"
}

variable "notebook_count" {
  description = "Number of AI Notebooks requested"
  type        = string
  default     = "1"
}

variable "organization_id" {
  description = "Organization ID where GCP Resources need to get spin up. It can be skipped if already setting folder_id"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Project name or ID, if it's an existing project."
  type        = string
  default     = "radlab-data-science"
}

variable "random_id" {
  description = "Adds a suffix of 4 random characters to the \`project_id\`"
  type        = string
  default     = null
}

variable "set_external_ip_policy" {
  description = "Enable org policy to allow External (Public) IP addresses on virtual machines."
  type        = bool
  default     = false
}

variable "set_shielded_vm_policy" {
  description = "Apply org policy to disable shielded VMs. {{UIMeta dependson=(set_external_ip_policy==true||enable_gpu_driver==true) updatesafe}}"
  type        = bool
  default     = true
}

variable "set_trustedimage_project_policy" {
  description = "Apply org policy to set the trusted image projects. {{UIMeta updatesafe order=1 }}"
  type        = bool
  default     = true
}

variable "subnet_name" {
  description = "Name of the subnet where to deploy the Notebooks. {{UIMeta group=3 dependson=(enable_gpu_driver==true||create_usermanaged_notebook==true&&create_network==true||set_external_ip_policy==true) mandatory}}"
  type        = string
  default     = "subnet-ai-notebook"
}

variable "trusted_users" {
  description = "The list of trusted users. {{UIMeta group=2 order=1 updatesafe }}"
  type        = set(string)
  default     = []
}

variable "zone" {
  description = "Cloud Zone associated to the AI Notebooks {{UIMeta group=1 order=1 options=us-central1-b,us-east1-a,us-west3-b,us-east4-c mandatory }}"
  type        = string
  default     = "us-east4-c"
  otherfield  = "bar"
}

variable "billing_budget_labels" {
  description = "A single label and value pair specifying that usage from only this set of labeled resources should be included in the budget. {{UIMeta group=0 order=11 updatesafe }}"
  type        = map(string)
  default     = {}
  validation {
    condition     = length(var.billing_budget_labels) <= 1
    error_message = "Only 0 or 1 labels may be supplied for the budget filter."
  }
}

variable "billing_budget_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded. {{UIMeta group=0 order=7 updatesafe }}"
  type        = list(number)
  default     = [0.5, 0.7, 1]
}

variable "billing_budget_services" {
  description = "A list of services ids to be included in the budget. If omitted, all services will be included in the budget. Service ids can be found at https://cloud.google.com/skus/. {{UIMeta group=0 order=12 updatesafe dependson=(enable_gpu_driver==true||set_external_ip_policy==true&&create_network==true||create_usermanaged_notebook==true)}}"
  type        = list(string)
  default     = null
}
`
