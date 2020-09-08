variable "team" {
    type = string
    description = "ECS Cluster name"
}

variable "tags" {
  type = map(string)
}

variable "capacity_providers" {
  type = list(string)
  default = ["EC2"]
}
