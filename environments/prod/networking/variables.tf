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

variable "env" {
  default     = "prod"
  type        = string
  description = "Deployment Environment"
}
