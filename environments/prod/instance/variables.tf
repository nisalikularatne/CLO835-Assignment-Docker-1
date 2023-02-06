# Default tags
variable "default_tags" {
  default = {
    "Owner" = "Nisali",
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}

# Name prefix
variable "prefix" {
  type        = string
  default     = "Nisali"
  description = "Name prefix"
}
variable "bucket_name" {
  default     = "prod-clo835-docker-assignment1"
  description = "S3 bucket name"
  type        = string
}

# Variable to signal the current environment
variable "env" {
  default     = "prod"
  type        = string
  description = "Deployment Environment"
}
variable "instance_type" {
  default     = "t2.micro"
  type        = string
  description = "The type of the instance to be deployed"
}

variable "linux_key_ec2" {
  default     = "prod-project"
  description = "Path to the public key to use in Linux VMs provisioning"
  type        = string
}
