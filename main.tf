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

# Create cloud sql instance
resource "google_sql_database_instance" "cloud_sql_instance" {
  name             = var.cloud_sql_instance_name
  database_version = var.cloud_sql_database_version
  region           = var.cloud_sql_region

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
resource "google_compute_instance" "webapp-instance" {
  machine_type              = var.machine_type
  name                      = var.instance_name
  allow_stopping_for_update = true
  zone                      = var.zone
  tags                      = var.tags

  boot_disk {
    auto_delete = true
    device_name = "webapp"

    initialize_params {
      image = data.google_compute_image.my_image.self_link
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }

    mode = "READ_WRITE"
  }

  network_interface {
    access_config {
      network_tier = var.network_tier
    }
    subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/webapp"
  }

  service_account {
    email  = google_service_account.logging_service_account.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

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
    echo "ENV=prod" >> /opt/webapp/.env

    # Mark script as run by creating a file
    touch /opt/.env_configured
    EOT
  }

  depends_on = [google_compute_subnetwork.app_subnets["webapp"]]
}


# Data block to fetch cloud dns zone configured in GCP
data "google_dns_managed_zone" "webapp_zone" {
  name = var.dns_managed_zone_name
}

# Create A record for webapp instance
resource "google_dns_record_set" "webapp_a_record" {
  name         = "${var.domain_name}."
  type         = "A"
  ttl          = var.a_record_ttl
  managed_zone = data.google_dns_managed_zone.webapp_zone.name
  rrdatas      = [google_compute_instance.webapp-instance.network_interface[0].access_config[0].nat_ip]
}
