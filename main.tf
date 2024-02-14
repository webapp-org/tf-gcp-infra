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
  project = "robust-doodad-412315"
  region  = "us-central1"
  zone    = "us-central1-c"
}
