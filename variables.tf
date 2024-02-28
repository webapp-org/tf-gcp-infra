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
    name                     = string
    cidr                     = string
    vpc                      = string
    private_ip_google_access = bool
  }))
  default = {
    "webapp" = {
      name                     = "webapp"
      cidr                     = "10.1.0.0/24"
      vpc                      = "app_vpc_network"
      private_ip_google_access = true
    },
    "db" = {
      name                     = "db"
      cidr                     = "10.2.0.0/24"
      vpc                      = "app_vpc_network"
      private_ip_google_access = false
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

# global address
variable "global_address_name" {
  type    = string
  default = "private-ip-range"
}

variable "global_address_purpose" {
  type    = string
  default = "VPC_PEERING"
}

variable "global_address_type" {
  type    = string
  default = "INTERNAL"
}

variable "global_address_prefix_length" {
  type    = number
  default = 24
}

variable "vpc_network_name" {
  type    = string
  default = "app_vpc_network"
}

# global service networking connection
variable "service_networking_service" {
  type    = string
  default = "servicenetworking.googleapis.com"
}



# Cloud sql
variable "cloud_sql_instance_name" {
  type    = string
  default = "my-cloud-sql-instance"
}

variable "cloud_sql_database_version" {
  type    = string
  default = "MYSQL_8_0"
}

variable "cloud_sql_region" {
  type    = string
  default = "us-central1"
}

variable "cloud_sql_tier" {
  type    = string
  default = "db-n1-standard-1"
}

variable "cloud_sql_availability_type" {
  type    = string
  default = "REGIONAL"
}

variable "cloud_sql_disk_type" {
  type    = string
  default = "PD_SSD"
}

variable "cloud_sql_disk_size" {
  type    = number
  default = 100
}

variable "cloud_sql_backup_enabled" {
  type    = bool
  default = true
}

variable "cloud_sql_binary_log_enabled" {
  type    = bool
  default = true
}

variable "cloud_sql_deletion_protection" {
  type    = bool
  default = false
}

variable "cloud_sql_database_name" {
  type    = string
  default = "webapp"
}
variable "cloud_sql_database_user_name" {
  type    = string
  default = "webapp"
}
variable "cloud_sql_database_port" {
  type    = number
  default = 8080
}

# webapp vm instance
variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "instance_name" {
  type    = string
  default = "webapp-instance"
}

variable "boot_disk_size" {
  type    = number
  default = 100
}

variable "boot_disk_type" {
  type    = string
  default = "pd-balanced"
}

variable "network_tier" {
  type    = string
  default = "PREMIUM"
}

variable "tags" {
  type    = list(string)
  default = ["deny-all", "allow-8080"]
}
