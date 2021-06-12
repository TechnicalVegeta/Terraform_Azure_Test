# Configure varialbes
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "rg_name" {}
variable "location" {}
variable "prefix" {
  default = "tfvmex"
}