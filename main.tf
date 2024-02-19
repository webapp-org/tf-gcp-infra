terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.15.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = var.project_id
  region  = var.region
  zone    = var.zone
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
