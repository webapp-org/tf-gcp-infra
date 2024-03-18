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
