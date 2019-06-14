// Generate an SSH on the fly, so we dont need to worry about it.
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

//Copy the SSH key to your local
resource "local_file" "ssh" {
  content  = tls_private_key.main.private_key_pem
  filename = "output/${terraform.workspace}-${var.region[terraform.workspace]}-${random_pet.main.id}-priv.pem"
}

