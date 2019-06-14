// Render cloud-init file for workers
data "template_file" "cloud_init" {
  template = file("${path.module}/files/cloud-init")

  vars = {
    kubernetes_version       = var.kubernetes_version
    username                 = var.username
    kubernetes_blob_endpoint = var.kubernetes_blob_endpoint
    sas_string               = var.sas_string
  }
}

