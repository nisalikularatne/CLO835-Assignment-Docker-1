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
  default     = "dev-clo835-docker-assignment1"
  description = "S3 bucket name"
  type        = string
}

# Variable to signal the current environment
variable "env" {
  default     = "dev"
  type        = string
  description = "Deployment Environment"
}
