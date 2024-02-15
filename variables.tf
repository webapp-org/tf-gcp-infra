variable "project_id" {
  type    = string
  default = "cloud-webapp-414413"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "subnets" {
  type = map(object({
    name = string
    cidr = string
  }))
  default = {
    "webapp" = {
      name = "webapp"
      cidr = "10.1.0.0/24"
    }
    "db" = {
      name = "db"
      cidr = "10.2.0.0/24"
    }
  }
}
