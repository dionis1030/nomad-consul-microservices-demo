variable "region" {
  description = "The AWS region to deploy to."
  default     = "us-east-1"
}

variable "ami" {
  description = "AMI ID"
  default = "ami-05f6402cb4229d253"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "subnet_id" {
  description = "Subnet ID"
}

variable "server_instance_type" {
  description = "The AWS instance type to use for servers."
  default     = "t2.medium"
}

variable "client_instance_type" {
  description = "The AWS instance type to use for clients."
  default     = "t2.medium"
}

variable "key_name" {}

variable "server_count" {
  description = "The number of servers to provision."
  default     = "1"
}

variable "client_count" {
  description = "The number of clients to provision."
  default     = "2"
}

variable "name_tag_prefix" {
  description = "prefixed to Name tag added to EC2 instances"
  default     = "nomad-consul"
}

variable "cluster_tag_value" {
  description = "Used by Consul to automatically form a cluster."
  default     = "nomad-consul-demo"
}

variable "owner_tag_value" {
  description = "Adds owner tag to EC2 instances"
  default = "NomadConsulDemo"
}

variable "ttl_tag_value" {
  description = "Adds TTL tag to EC2 instances for reaping purposes. Reaping is only done for instances deployed by HashiCorp SEs. In any case, -1 means no reaping."
  default = "-1"
}

variable "token_for_nomad" {
  description = "A Vault token for use by Nomad"
}

variable "vault_url" {
  description = "URL of your Vault server including port"
}
