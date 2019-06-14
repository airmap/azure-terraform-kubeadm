locals {
  role    = "worker"
  service = "kubernetes"
  purpose = "Kubernetes Workers"
}

// Generate a random string for the password as required
resource "random_string" "vm-login-password" {
  length           = 16
  special          = true
  override_special = "!@#%&-_"
}

