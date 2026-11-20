locals {
  credentials = {
    username = "moderngitopsadmin"
    password = resource.random_password.password_secret.result
  }
  databases = concat(["backend"], var.databases)
  helm_values = [{
    mysql = {
      auth = {
        database       = "site"
        username       = local.credentials.username
        password       = local.credentials.password
        existingSecret = "mysql-secrets"
      }
      image = {
        repository = "bitnamilegacy/mysql"
        debug      = var.debug
      }
      metrics = {
        enabled = var.enable_service_monitor
        serviceMonitor = {
          enabled       = var.enable_service_monitor
          interval      = "10s"
          scrapeTimeout = "5s"
        }
        image = {
          repository = "bitnamilegacy/mysqld-exporter"
        }
      }
      primary = {
        persistence = {
          size = "${var.persistence_size}Gi"
        }
      }
      secondary = {
        persistence = {
          size = "${var.persistence_size}Gi"
        }
      }
      volumePermissions = {
        enabled = true
        image = {
          repository = "bitnamilegacy/os-shell"
        }
      }
      initdbScripts = {
        "init.sql" = <<-EOT
          %{for db in local.databases~}
          CREATE DATABASE ${db};
          %{endfor~}
        EOT
      }
    }
  }]
}
