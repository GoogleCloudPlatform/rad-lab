export const DATA_DEFAULT_VARS = `

variable "billing_id" {
  description = "Billing ID associated to the GCP Resources {{UIMeta group=1 order=1 }}"
  type        = string
}

variable "organization_id" {
  description = "Organization ID where GCP Resources need to get spin up. It can be skipped if already setting folder_id {{UIMeta group=2 order=1 }}"
  type        = string
  default     = ""
}

variable "folder_id" {
  description = "Folder ID where the project should be created. It can be skipped if already setting organization_id. Leave blank if the project should be created directly underneath the Organization node. {{UIMeta group=3 order=1 }}"
  type        = string
  default     = ""
}

variable "region" {
  description = "The region to this instance {{UIMeta group=4 order=1 options=region1,region2,region3 }}"
  type        = string
  default     = "region3"
}

variable "zone" {
  description = "Cloud Zone associated to the AI Notebooks {{UIMeta group=4 order=2 options=us-central1-b,us-east1-a,us-west3-b,us-east4-c }}"
  type        = string
  default     = "us-east4-c"
}
}`
