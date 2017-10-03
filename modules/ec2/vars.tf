##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
  default = "JenkinsKeyPair"
}

variable "network_address_space" {
  default = "172.16.0.0/16"
}
variable "subnet1_address_space" {
  default = "172.16.0.0/24"
}
variable "username" {
  default = "alexli"
}
variable "password" {
  default = "password"
}
