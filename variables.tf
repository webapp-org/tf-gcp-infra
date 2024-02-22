variable "project_id" {
  type    = string
  default = "csye6225-dev-415023"
}

variable "region" {
  type    = string
  default = "us-central1"
}
variable "zone" {
  type    = string
  default = "us-central1-c"
}

variable "vpcs" {
  type = map(object({
    name                            = string
    auto_create_subnetworks         = bool
    routing_mode                    = string
    delete_default_routes_on_create = bool
  }))
  default = {
    "app_vpc_network" = {
      name                            = "app-vpc-network"
      auto_create_subnetworks         = false
      routing_mode                    = "REGIONAL"
      delete_default_routes_on_create = true
    }
    # "app_vpc_network_2" = {
    #   name                            = "app-vpc-network-2"
    #   auto_create_subnetworks         = false
    #   routing_mode                    = "REGIONAL"
    #   delete_default_routes_on_create = true
    # }
  }
}

variable "subnets" {
  type = map(object({
    name = string
    cidr = string
    vpc  = string
  }))
  default = {
    "webapp" = {
      name = "webapp"
      cidr = "10.1.0.0/24"
      vpc  = "app_vpc_network"
    },
    "db" = {
      name = "db"
      cidr = "10.2.0.0/24"
      vpc  = "app_vpc_network"
    }
    # "webapp-2" = {
    #   name = "webapp-2"
    #   cidr = "10.3.0.0/24"
    #   vpc  = "app_vpc_network_2"
    # },
    # "db-2" = {
    #   name = "db-2"
    #   cidr = "10.4.0.0/24"
    #   vpc  = "app_vpc_network_2"
    # }
  }
}

variable "routes" {
  type = map(object({
    name             = string
    network          = string
    next_hop_gateway = string
    dest_range       = string
  }))
  default = {
    "app_vpc_route" = {
      name             = "vpc-route"
      network          = "app_vpc_network"
      next_hop_gateway = "default-internet-gateway"
      dest_range       = "0.0.0.0/0"
    }
    # "app_vpc_route_2" = {
    #   name             = "vpc-route-2"
    #   network          = "app_vpc_network_2"
    #   next_hop_gateway = "default-internet-gateway"
    #   dest_range       = "0.0.0.0/0"
    # }
  }
}

# Allowed fire wall rules
variable "allow_firewall_rules" {
  type = map(object({
    name          = string
    protocol      = string
    ports         = list(string)
    source_ranges = list(string)
    network       = string
    priority      = number
  }))
  default = {
    allow_8080 = {
      name          = "allow-8080"
      protocol      = "tcp"
      ports         = ["8080"]
      source_ranges = ["0.0.0.0/0"]
      network       = "app_vpc_network"
      priority      = 999
    }
  }
}

# Denied fire wall rules
variable "deny_firewall_rules" {
  type = map(object({
    name          = string
    protocol      = string
    ports         = list(string)
    source_ranges = list(string)
    network       = string
    priority      = number
  }))
  default = {
    deny_all = {
      name          = "deny-all"
      protocol      = "all"
      ports         = []
      source_ranges = ["0.0.0.0/0"]
      network       = "app_vpc_network"
      priority      = 1000
    }
  }
}
