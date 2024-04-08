# Creating a service account which will be attached to the webapp instance for logging
resource "google_service_account" "logging_service_account" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
}

# Bind IAM Roles to the service account
# Logging Admin role
resource "google_project_iam_member" "logging_admin" {
  project = var.project_id
  role    = var.logging_admin_role
  member  = "serviceAccount:${google_service_account.logging_service_account.email}"
}

# Monitoring Metric Writer role
resource "google_project_iam_member" "metric_writer" {
  project = var.project_id
  role    = var.metric_writer_role
  member  = "serviceAccount:${google_service_account.logging_service_account.email}"
}

# Pub/Sub Publisher role
resource "google_project_iam_member" "pubsub_editor" {
  project = var.project_id
  role    = var.pubsub_editor_role
  member  = "serviceAccount:${google_service_account.logging_service_account.email}"
}

# Token creator role
resource "google_project_iam_member" "pubsub_sa_token_creator" {
  project = var.project_id
  role    = var.token_creator_role
  member  = "serviceAccount:${google_service_account.logging_service_account.email}"
}

# Cloud Functions Invoker Role
resource "google_project_iam_member" "cloud_functions_invoker" {
  project = var.project_id
  role    = var.cloudfunction_invoker_role
  member  = "serviceAccount:${google_service_account.logging_service_account.email}"
}

# Cloud Run Invoker Role
resource "google_project_iam_member" "cloud_run_invoker" {
  project = var.project_id
  role    = var.cloudfunction_run_invoker_role
  member  = "serviceAccount:${google_service_account.logging_service_account.email}"
}

resource "random_id" "key_ring_suffix" {
  byte_length = var.key_ring_suffix_byte_length
}

resource "google_kms_key_ring" "key_ring" {
  name     = "webapp-key-ring-${random_id.key_ring_suffix.hex}"
  location = var.region
}

resource "google_kms_crypto_key" "vm_key" {
  name            = var.key_name_vm
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = var.rotation_period
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key" "cloudsql_key" {
  name            = var.key_name_cloudsql
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = var.rotation_period
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key" "gcs_key" {
  name            = var.key_name_gcs
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = var.rotation_period
  lifecycle {
    prevent_destroy = false
  }
}

# Create vpc
resource "google_compute_network" "app_vpcs" {
  for_each = var.vpcs

  name                            = each.value.name
  auto_create_subnetworks         = each.value.auto_create_subnetworks
  routing_mode                    = each.value.routing_mode
  delete_default_routes_on_create = each.value.delete_default_routes_on_create
}

# Create subnets
resource "google_compute_subnetwork" "app_subnets" {
  for_each = var.subnets

  name                     = each.value.name
  ip_cidr_range            = each.value.cidr
  network                  = google_compute_network.app_vpcs[each.value.vpc].self_link
  region                   = var.region
  private_ip_google_access = each.value.private_ip_google_access
}

# Create a global address
resource "google_compute_global_address" "private_ip_range" {
  name          = var.global_address_name
  purpose       = var.global_address_purpose
  address_type  = var.global_address_type
  prefix_length = var.global_address_prefix_length
  network       = google_compute_network.app_vpcs[var.vpc_network_name].self_link
}

# Create a private vpc connection
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.app_vpcs[var.vpc_network_name].self_link
  service                 = var.service_networking_service
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]

  depends_on = [
    google_compute_network.app_vpcs,
    google_compute_global_address.private_ip_range
  ]
}

resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  project  = var.project_id
  provider = google-beta
  service  = "sqladmin.googleapis.com"
}

resource "google_project_iam_member" "cloud_sql_sa_kms_role" {
  project = var.project_id
  role    = var.kms_role
  member  = "serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}"
}

# Create cloud sql instance
resource "google_sql_database_instance" "cloud_sql_instance" {
  name                = var.cloud_sql_instance_name
  database_version    = var.cloud_sql_database_version
  region              = var.cloud_sql_region
  encryption_key_name = google_kms_crypto_key.cloudsql_key.id

  settings {
    tier              = var.cloud_sql_tier
    availability_type = var.cloud_sql_availability_type
    disk_type         = var.cloud_sql_disk_type
    disk_size         = var.cloud_sql_disk_size
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.app_vpcs["app_vpc_network"].self_link
    }

    backup_configuration {
      enabled            = var.cloud_sql_backup_enabled
      binary_log_enabled = var.cloud_sql_binary_log_enabled
    }
  }

  deletion_protection = var.cloud_sql_deletion_protection

  depends_on = [
    google_compute_global_address.private_ip_range,
    google_service_networking_connection.private_vpc_connection
  ]
}

# Create db for sql instance
resource "google_sql_database" "webapp_db" {
  name     = var.cloud_sql_database_name
  instance = google_sql_database_instance.cloud_sql_instance.name
}

# Generate password for sql instance
resource "random_password" "webapp_db_user_password" {
  length  = 16
  special = false
}

# Create user for webapp db
resource "google_sql_user" "webapp_db_user" {
  name     = var.cloud_sql_database_user_name
  instance = google_sql_database_instance.cloud_sql_instance.name
  password = random_password.webapp_db_user_password.result
}

# Add routes
resource "google_compute_route" "vpc_routes" {
  for_each = var.routes

  name             = each.value.name
  network          = google_compute_network.app_vpcs[each.value.network].self_link
  next_hop_gateway = each.value.next_hop_gateway
  dest_range       = each.value.dest_range
}

# Create allowed firewall
resource "google_compute_firewall" "allowed_firewalls" {
  for_each = var.allow_firewall_rules

  name     = each.value.name
  network  = google_compute_network.app_vpcs[each.value.network].self_link
  priority = each.value.priority

  allow {
    protocol = each.value.protocol
    ports    = each.value.ports
  }

  source_ranges = each.value.source_ranges
  target_tags   = [each.value.name]
}

# Create denied firewall
resource "google_compute_firewall" "denied_firewalls" {
  for_each = var.deny_firewall_rules

  name     = each.value.name
  network  = google_compute_network.app_vpcs[each.value.network].self_link
  priority = each.value.priority

  deny {
    protocol = each.value.protocol
  }
  source_ranges = each.value.source_ranges
  target_tags   = [each.value.name]
}

# Data block to fetch all images from project
data "google_compute_image" "my_image" {
  project     = var.project_id
  filter      = "family:*"
  most_recent = true
}

# Adding webapp vm instance
# resource "google_compute_instance" "webapp-instance" {
#   machine_type              = var.machine_type
#   name                      = var.instance_name
#   allow_stopping_for_update = true
#   zone                      = var.zone
#   tags                      = var.tags

#   boot_disk {
#     auto_delete = true
#     device_name = "webapp"

#     initialize_params {
#       image = data.google_compute_image.my_image.self_link
#       size  = var.boot_disk_size
#       type  = var.boot_disk_type
#     }

#     mode = "READ_WRITE"
#   }

#   network_interface {
#     access_config {
#       network_tier = var.network_tier
#     }
#     subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/webapp"
#   }

#   service_account {
#     email  = google_service_account.logging_service_account.email
#     scopes = ["https://www.googleapis.com/auth/cloud-platform"]
#   }

#   metadata = {
#     startup-script = <<-EOT
#     #!/bin/bash
#     # Check if the script has already run
#     if [ -f "/opt/.env_configured" ]; then
#       exit 0
#     fi

#     # Populate the .env file
#     echo "DATABASE=${var.cloud_sql_database_name}" > /opt/webapp/.env
#     echo "USERNAME=${var.cloud_sql_database_user_name}" >> /opt/webapp/.env
#     echo "PASSWORD=${random_password.webapp_db_user_password.result}" >> /opt/webapp/.env
#     echo "HOST=${google_sql_database_instance.cloud_sql_instance.private_ip_address}" >> /opt/webapp/.env
#     echo "PORT=${var.cloud_sql_database_port}" >> /opt/webapp/.env
#     echo "DOMAIN_NAME=${var.domain_name}" >> /opt/webapp/.env
#     echo "ENV=prod" >> /opt/webapp/.env
#     echo "PUBSUB_TOPIC_NAME=${google_pubsub_topic.pubsub_topic.name}" >> /opt/webapp/.env
#     # Mark script as run by creating a file
#     touch /opt/.env_configured
#     EOT
#   }

#   depends_on = [
#     google_service_account.logging_service_account,
#     google_compute_subnetwork.app_subnets["webapp"]
#   ]
# }

# Create a Google Cloud Storage Bucket for the Function Code
resource "random_id" "bucket_suffix" {
  byte_length = var.bucket_suffix_byte_length
}

data "google_storage_project_service_account" "gcs_account" {
  project = var.project_id
}

resource "google_kms_crypto_key_iam_binding" "bucket_crypto_key_iam" {
  provider      = google-beta
  crypto_key_id = google_kms_crypto_key.gcs_key.id
  role          = var.kms_role
  members = [
    "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
  ]
}

resource "google_storage_bucket" "function_code_bucket" {
  name          = "${var.function_code_bucket_name_prefix}-${random_id.bucket_suffix.hex}"
  location      = var.function_code_bucket_location
  force_destroy = true
  encryption {
    default_kms_key_name = google_kms_crypto_key.gcs_key.id
  }
  depends_on = [
    google_kms_crypto_key_iam_binding.bucket_crypto_key_iam
  ]
}

resource "google_storage_bucket_object" "function_code" {
  name   = var.function_code_file_name
  bucket = google_storage_bucket.function_code_bucket.name
  source = var.function_code_file_name
}

# VPC connector 
resource "google_vpc_access_connector" "webapp_connector" {
  name          = var.vpc_connector_name
  region        = var.region
  network       = google_compute_network.app_vpcs["app_vpc_network"].id
  ip_cidr_range = var.vpc_connector_ip_cidr_range
}

# Setup Google Cloud Pub/Sub Topic and Subscription
resource "google_pubsub_topic" "pubsub_topic" {
  name                       = var.pubsub_topic_name
  message_retention_duration = var.pubsub_topic_retention_duration
}

resource "google_pubsub_subscription" "pubsub_subscription" {
  name                 = var.pubsub_subscription_name
  topic                = google_pubsub_topic.pubsub_topic.name
  ack_deadline_seconds = var.pubsub_ack_deadline_seconds
}

resource "google_cloudfunctions2_function" "webapp_email_function" {
  name        = var.cloud_function_name
  description = var.cloud_function_description
  location    = var.region

  build_config {
    entry_point = var.cloud_function_entry_point
    runtime     = var.cloud_function_runtime

    source {
      storage_source {
        bucket = google_storage_bucket.function_code_bucket.name
        object = google_storage_bucket_object.function_code.name
      }
    }
  }

  service_config {
    available_memory              = var.cloud_function_available_memory
    available_cpu                 = var.cloud_function_available_cpu
    timeout_seconds               = var.cloud_function_timeout_seconds
    max_instance_count            = var.cloud_function_max_instance_count
    vpc_connector                 = google_vpc_access_connector.webapp_connector.id
    vpc_connector_egress_settings = var.cloud_function_vpc_connector_egress_settings
    service_account_email         = google_service_account.logging_service_account.email
    environment_variables = {
      MAILGUN_API_KEY      = var.mailgun_api_key
      DATABASE             = var.cloud_sql_database_name
      USERNAME             = var.cloud_sql_database_user_name
      PASSWORD             = random_password.webapp_db_user_password.result
      HOST                 = google_sql_database_instance.cloud_sql_instance.private_ip_address
      DATABASE_PORT        = var.cloud_sql_database_port
      MAILGUN_SENDER_EMAIL = var.mailgun_sender_email
      MAILGUN_DOMAIN       = var.mailgun_domain
    }
  }

  event_trigger {
    event_type            = var.cloud_function_event_type
    pubsub_topic          = google_pubsub_topic.pubsub_topic.id
    retry_policy          = var.cloud_function_retry_policy
    service_account_email = google_service_account.logging_service_account.email
    trigger_region        = var.region
  }
}



# Data block to fetch cloud dns zone configured in GCP
data "google_dns_managed_zone" "webapp_zone" {
  name = var.dns_managed_zone_name
}

# Create A record for webapp instance
# resource "google_dns_record_set" "webapp_a_record" {
#   name         = "${var.domain_name}."
#   type         = "A"
#   ttl          = var.a_record_ttl
#   managed_zone = data.google_dns_managed_zone.webapp_zone.name
#   rrdatas      = [google_compute_instance.webapp-instance.network_interface[0].access_config[0].nat_ip]
# }

#  Assignment 8 
resource "google_project_iam_member" "kms_role_to_compute_service_account" {
  project = var.project_id
  role    = var.kms_role
  member  = var.kms_service_account
}

#  Instance template
resource "google_compute_region_instance_template" "webapp_instance_template" {
  name_prefix  = var.instance_name_prefix
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = data.google_compute_image.my_image.self_link
    auto_delete  = true
    boot         = true
    disk_size_gb = var.boot_disk_size
    disk_type    = var.boot_disk_type
    disk_encryption_key {
      kms_key_self_link = google_kms_crypto_key.vm_key.id
    }
  }

  network_interface {
    network    = google_compute_network.app_vpcs[var.vpc_network_name].self_link
    subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/webapp"
    access_config {
    }
  }

  service_account {
    email  = google_service_account.logging_service_account.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  tags = var.tags

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      # Check if the script has already run
      if [ -f "/opt/.env_configured" ]; then
        exit 0
      fi
      # Populate the .env file
      echo "DATABASE=${var.cloud_sql_database_name}" > /opt/webapp/.env
      echo "USERNAME=${var.cloud_sql_database_user_name}" >> /opt/webapp/.env
      echo "PASSWORD=${random_password.webapp_db_user_password.result}" >> /opt/webapp/.env
      echo "HOST=${google_sql_database_instance.cloud_sql_instance.private_ip_address}" >> /opt/webapp/.env
      echo "PORT=${var.cloud_sql_database_port}" >> /opt/webapp/.env
      echo "DOMAIN_NAME=${var.domain_name}" >> /opt/webapp/.env
      echo "ENV=prod" >> /opt/webapp/.env
      echo "PUBSUB_TOPIC_NAME=${google_pubsub_topic.pubsub_topic.name}" >> /opt/webapp/.env
      # Mark script as run by creating a file
      touch /opt/.env_configured
    EOT
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Regional Health check
resource "google_compute_region_health_check" "regional_health_check" {
  name   = var.health_check_name
  region = var.region

  http_health_check {
    port         = var.http_port
    request_path = var.request_path
  }

  timeout_sec         = var.timeout_sec
  check_interval_sec  = var.check_interval_sec
  unhealthy_threshold = var.unhealthy_threshold
  healthy_threshold   = var.healthy_threshold
}

# Manage Instance Groups
resource "google_compute_region_instance_group_manager" "webapp_mig" {
  name               = var.mig_name
  region             = var.region
  base_instance_name = var.base_instance_name

  version {
    name              = "primary"
    instance_template = google_compute_region_instance_template.webapp_instance_template.id
  }

  named_port {
    name = var.named_port_name
    port = var.named_port_port
  }

  distribution_policy_zones = var.distribution_policy_zones

  auto_healing_policies {
    health_check      = google_compute_region_health_check.regional_health_check.self_link
    initial_delay_sec = var.auto_healing_initial_delay_sec
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaler
resource "google_compute_region_autoscaler" "webapp_autoscaler" {
  name   = var.autoscaler_name
  target = google_compute_region_instance_group_manager.webapp_mig.id
  region = var.region

  autoscaling_policy {
    max_replicas    = var.autoscaler_max_replicas
    min_replicas    = var.autoscaler_min_replicas
    cooldown_period = var.autoscaler_cooldown_period

    cpu_utilization {
      target = var.cpu_utilization_target
    }
  }
}

# Load balancer
module "gce-lb-http" {
  source                = "terraform-google-modules/lb-http/google"
  version               = "~> 10.0"
  project               = var.project_id
  name                  = var.lb_name
  target_tags           = var.lb_target_tags
  load_balancing_scheme = var.lb_load_balancing_scheme

  ssl                             = var.ssl_enabled
  managed_ssl_certificate_domains = var.managed_ssl_certificate_domains
  http_forward                    = var.http_forward_enabled

  network = google_compute_network.app_vpcs["app_vpc_network"].name

  backends = {
    default = {
      description = var.backend_description
      protocol    = var.backend_protocol
      port_name   = var.backend_port_name
      timeout_sec = var.backend_timeout_sec
      enable_cdn  = var.backend_enable_cdn

      log_config = {
        enable      = var.backend_log_enable
        sample_rate = var.backend_log_sample_rate
      }

      health_check = {
        check_interval_sec  = var.health_check_check_interval_sec
        timeout_sec         = var.health_check_timeout_sec
        healthy_threshold   = var.health_check_healthy_threshold
        unhealthy_threshold = var.health_check_unhealthy_threshold
        request_path        = var.health_check_request_path
        port                = var.health_check_port
      }

      groups = [
        {
          group = google_compute_region_instance_group_manager.webapp_mig.instance_group
        }
      ]

      iap_config = {
        enable = var.iap_enable
      }
    }
  }
}

# DNS A record 
resource "google_dns_record_set" "webapp_a_record" {
  name         = "${var.domain_name}."
  type         = "A"
  ttl          = var.a_record_ttl
  managed_zone = data.google_dns_managed_zone.webapp_zone.name
  rrdatas      = [module.gce-lb-http.external_ip]
}
