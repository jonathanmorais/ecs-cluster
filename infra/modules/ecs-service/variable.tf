variable "cluster" {
  type        = string
  description = "ECS Cluster name"
}

variable "application" {
  type = object({
    name        = string
    version     = string
    environment = string
  })
}

variable "container" {
  type = object({
    image  = string
    cpu    = string
    memory = string
    port   = string
  })
}


variable "scale" {
  type = object({
    min = string
    max = string
    cpu = string
  })
}


variable "config" {
  type = object({
    environment = list(map(string))
  })
}

variable "network" {
  type = object({
    vpc             = string
    subnets         = list(string)
    security_groups = list(string)
  })
}

variable "service_policy" {
  type        = string
  description = "Policy to be attached on service execution role"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
}

locals {
  service_id = "${var.application.name}-${var.application.version}-${var.application.environment}"
}

variable "capacity_provider" {
  type = string
}

variable "alb" {
  type = object({
    enable             = bool
    health             = string
    public             = bool
    subnets            = list(string)
    security_groups    = list(string)
    certificate_domain = string
    idle_timeout       = number
  })

  default = {
    enable             = false
    health             = ""
    public             = false
    subnets            = []
    security_groups    = []
    certificate_domain = ""
    idle_timeout       = 0
  }
}

