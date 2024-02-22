

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

  name          = each.value.name
  ip_cidr_range = each.value.cidr
  network       = google_compute_network.app_vpcs[each.value.vpc].self_link
  region        = var.region
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

# Adding vm
resource "google_compute_instance" "webapp-instance" {
  machine_type              = "e2-medium"
  name                      = "webapp-instance"
  allow_stopping_for_update = true
  zone                      = var.zone
  tags                      = ["deny-all", "allow-8080"]
  boot_disk {
    auto_delete = true
    device_name = "webapp"

    initialize_params {
      image = data.google_compute_image.my_image.self_link
      # image = "projects/robust-doodad-412315/global/images/packer-1708390415"
      size = 100
      type = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }
    subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/webapp"
  }

  depends_on = [google_compute_subnetwork.app_subnets["webapp"]]
}


output "fetched_image_details" {
  value = {
    name          = data.google_compute_image.my_image.name
    creation_time = data.google_compute_image.my_image.creation_timestamp
  }
}
