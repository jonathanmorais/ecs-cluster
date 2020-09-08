variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "target_capacity" {
  type = number
}

variable "network" {
  type = object({
    subnets         = list(string)
    security_groups = list(string)
  })
}

variable "tags" {
  type = map(string)
}

variable "asg_tags" {
  type = list(map(string))
}

variable "ecs_cluster" {
  type = string
}

variable "name" {
  type = string
}

variable "instace_type" {
  type = string
}