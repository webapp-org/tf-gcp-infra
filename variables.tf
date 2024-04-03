variable "project_id" {
  type    = string
  default = "csye6225-dev-415023"
}

variable "region" {
  type    = string
  default = "us-east1"
}
variable "zone" {
  type    = string
  default = "us-east1-b"
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
      source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
      network       = "app_vpc_network"
      priority      = 999
    }
    # allow_ssh = {
    #   name          = "allow-ssh"
    #   protocol      = "tcp"
    #   ports         = ["22"]
    #   source_ranges = ["0.0.0.0/0"]
    #   network       = "app_vpc_network"
    #   priority      = 999
    # }
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
      priority      = 1100
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
  default = "us-east1"
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

# DNS and A record
variable "dns_managed_zone_name" {
  type    = string
  default = "cloud-webapp-zone"
}

variable "domain_name" {
  type    = string
  default = "chinmaygulhane.me"
}

variable "a_record_ttl" {
  type    = number
  default = 300
}

# Service account
variable "service_account_id" {
  default = "vm-logging-service-account"
}

variable "service_account_display_name" {
  default = "VM logging service account"
}

variable "logging_admin_role" {
  default = "roles/logging.admin"
}

variable "metric_writer_role" {
  default = "roles/monitoring.metricWriter"
}

variable "pubsub_editor_role" {
  type    = string
  default = "roles/pubsub.editor"
}

variable "token_creator_role" {
  type    = string
  default = "roles/iam.serviceAccountTokenCreator"
}

# Google cloud storage for function
variable "function_code_bucket_name_prefix" {
  default = "webapp-send-email-function-code-bucket"
}

variable "function_code_bucket_location" {
  default = "US"
}

variable "bucket_suffix_byte_length" {
  default = 2
}

variable "function_code_file_name" {
  default = "serverless-main.zip"
}


# VPC connector
variable "vpc_connector_name" {
  default = "webapp-vpc-connector"
}

variable "vpc_connector_ip_cidr_range" {
  default = "10.8.0.0/28"
}

# pub/sub topic and name
variable "pubsub_topic_name" {
  default = "webapp-email-topic"
}

variable "pubsub_topic_retention_duration" {
  default = "604800s" # 7 days
}

variable "pubsub_subscription_name" {
  default = "webapp-email-subscription"
}

variable "pubsub_ack_deadline_seconds" {
  default = 20
}

# cloud function
variable "cloud_function_name" {
  default = "webapp_email_function"
}

variable "cloud_function_description" {
  default = "Cloud Webapp Email Function"
}

variable "cloud_function_entry_point" {
  default = "sendEmail"
}

variable "cloud_function_runtime" {
  default = "nodejs20"
}

variable "cloud_function_available_memory" {
  default = "128Mi"
}
variable "cloud_function_available_cpu" {
  default = "1"
}

variable "cloud_function_timeout_seconds" {
  default = 540
}

variable "cloud_function_max_instance_count" {
  default = 1
}

variable "cloud_function_vpc_connector_egress_settings" {
  default = "PRIVATE_RANGES_ONLY"
}

variable "mailgun_api_key" {
  default = "20e98bda0732db1d6bc0220a4de06b97-309b0ef4-c6f3b875"
}

variable "mailgun_sender_email" {
  default = "Cloud Webapp <mailgun@mail.chinmaygulhane.me>"
}

variable "mailgun_domain" {
  default = "mail.chinmaygulhane.me"
}

variable "cloud_function_event_type" {
  default = "google.cloud.pubsub.topic.v1.messagePublished"
}

variable "cloud_function_retry_policy" {
  default = "RETRY_POLICY_RETRY"
}
