resource "google_secret_manager_secret" "project_id" {
  project   = var.project_id
  secret_id = "PROJECT_ID"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "project_id_version" {
  secret      = google_secret_manager_secret.project_id.id
  secret_data = var.project_id
}

resource "google_secret_manager_secret" "project_region" {
  project   = var.project_id
  secret_id = "PROJECT_REGION"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "project_region_version" {
  secret      = google_secret_manager_secret.project_region.id
  secret_data = var.region
}

resource "google_secret_manager_secret" "cloud_sql_database_name" {
  project   = var.project_id
  secret_id = "CLOUD_SQL_DATABASE_NAME"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "cloud_sql_database_name_version" {
  secret      = google_secret_manager_secret.cloud_sql_database_name.id
  secret_data = var.cloud_sql_database_name
}

resource "google_secret_manager_secret" "cloud_sql_database_user_name" {
  project   = var.project_id
  secret_id = "CLOUD_SQL_DATABASE_USER_NAME"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "cloud_sql_database_user_name_version" {
  secret      = google_secret_manager_secret.cloud_sql_database_user_name.id
  secret_data = var.cloud_sql_database_user_name
}

resource "google_secret_manager_secret" "cloud_sql_database_port" {
  project   = var.project_id
  secret_id = "CLOUD_SQL_DATABASE_PORT"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "cloud_sql_database_port_version" {
  secret      = google_secret_manager_secret.cloud_sql_database_port.id
  secret_data = var.cloud_sql_database_port
}

resource "google_secret_manager_secret" "db_password" {
  project   = var.project_id
  secret_id = "DB_PASSWORD"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.webapp_db_user_password.result
}

resource "google_secret_manager_secret" "cloud_sql_instance_private_ip" {
  project   = var.project_id
  secret_id = "CLOUD_SQL_INSTANCE_PRIVATE_IP"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "cloud_sql_instance_ip_version" {
  secret      = google_secret_manager_secret.cloud_sql_instance_private_ip.id
  secret_data = google_sql_database_instance.cloud_sql_instance.private_ip_address
}

resource "google_secret_manager_secret" "domain_name" {
  project   = var.project_id
  secret_id = "DOMAIN_NAME"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "domain_name_version" {
  secret      = google_secret_manager_secret.domain_name.id
  secret_data = var.domain_name
}

resource "google_secret_manager_secret" "pubsub_topic_name" {
  project   = var.project_id
  secret_id = "PUBSUB_TOPIC_NAME"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "pubsub_topic_version" {
  secret      = google_secret_manager_secret.pubsub_topic_name.id
  secret_data = google_pubsub_topic.pubsub_topic.name
}


resource "google_secret_manager_secret" "vm_kms_key" {
  project   = var.project_id
  secret_id = "VM_KMS_KEY"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "vm_kms_key_version" {
  secret      = google_secret_manager_secret.vm_kms_key.id
  secret_data = google_kms_crypto_key.vm_key.id
}

resource "google_secret_manager_secret" "vm_template_machine_type" {
  project   = var.project_id
  secret_id = "VM_TEMPLATE_MACHINE_TYPE"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "vm_template_machine_type_version" {
  secret      = google_secret_manager_secret.vm_template_machine_type.id
  secret_data = var.machine_type
}

resource "google_secret_manager_secret" "vm_template_boot_disk_type" {
  project   = var.project_id
  secret_id = "VM_TEMPLATE_BOOT_DISK_TYPE"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "vm_template_boot_disk_type_version" {
  secret      = google_secret_manager_secret.vm_template_boot_disk_type.id
  secret_data = var.boot_disk_type
}

resource "google_secret_manager_secret" "vm_template_boot_disk_size" {
  project   = var.project_id
  secret_id = "VM_TEMPLATE_BOOT_DISK_SIZE"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "vm_template_boot_disk_size_version" {
  secret      = google_secret_manager_secret.vm_template_boot_disk_size.id
  secret_data = var.boot_disk_size
}

resource "google_secret_manager_secret" "vm_template_service_account" {
  project   = var.project_id
  secret_id = "VM_TEMPLATE_SERVICE_ACCOUNT"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "vm_template_service_account_version" {
  secret      = google_secret_manager_secret.vm_template_service_account.id
  secret_data = google_service_account.vm_service_account.email
}

resource "google_secret_manager_secret" "vm_template_service_account_scope" {
  project   = var.project_id
  secret_id = "VM_TEMPLATE_SERVICE_ACCOUNT_SCOPE"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "vm_template_service_account_scope_version" {
  secret      = google_secret_manager_secret.vm_template_service_account_scope.id
  secret_data = "https://www.googleapis.com/auth/cloud-platform"
}

resource "google_secret_manager_secret" "vm_template_subnet" {
  project   = var.project_id
  secret_id = "VM_TEMPLATE_SUBNET"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "vm_template_subnet_version" {
  secret      = google_secret_manager_secret.vm_template_subnet.id
  secret_data = "webapp"
}

resource "google_secret_manager_secret" "vm_template_tage" {
  project   = var.project_id
  secret_id = "VM_TEMPLATE_TAGS"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "vm_template_tags_version" {
  secret      = google_secret_manager_secret.vm_template_tage.id
  secret_data = "deny-all,allow-8080"
}

resource "google_secret_manager_secret" "vm_template_mig_name" {
  project   = var.project_id
  secret_id = "VM_TEMPLATE_MIG_NAME"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "vm_template_mig_name_version" {
  secret      = google_secret_manager_secret.vm_template_mig_name.id
  secret_data = var.mig_name
}
