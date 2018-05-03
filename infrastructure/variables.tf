variable "tenant_id" {}
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "admin_username" {}
variable "admin_password" {}

variable "resource_group_name" {
  default = "sugcon7-rg"
}

variable "build_windows_vm_size" {
  default = "Standard_D2_v3"
}

variable "runtime_linux_vm_count" {
  default = 2
}

variable "runtime_linux_vm_size" {
  default = "Standard_A2_v2"
}

variable "runtime_windows_vm_count" {
  default = 3
}

variable "runtime_windows_vm_size" {
  default = "Standard_A4_v2"
}
