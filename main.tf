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
  zone    = "us-central1-c"
}

# Create vpc
resource "google_compute_network" "webapp_vpc_network" {
  name                            = "webapp-vpc-network"
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
  delete_default_routes_on_create = true
}

# Create subnets
resource "google_compute_subnetwork" "webapp_subnet" {
  for_each = var.subnets

  name          = each.value.name
  ip_cidr_range = each.value.cidr
  network       = google_compute_network.webapp_vpc_network.self_link
  region        = var.region

}

# Create web app route
resource "google_compute_route" "webapp_route" {
  name             = "webapp-route"
  network          = google_compute_network.webapp_vpc_network.self_link
  next_hop_gateway = "default-internet-gateway"
  dest_range       = "0.0.0.0/0"
}
