output "fetched_image_details" {
  value = {
    name          = data.google_compute_image.my_image.name
    creation_time = data.google_compute_image.my_image.creation_timestamp
  }
}

output "webapp_db_user_password" {
  value     = random_password.webapp_db_user_password.result
  sensitive = true
}

output "key_ring_name" {
  value = google_kms_key_ring.key_ring.name
}

output "vm_key_path" {
  value = google_kms_crypto_key.vm_key.id
}
