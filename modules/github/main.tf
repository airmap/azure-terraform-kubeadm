provider "github" {
  token        = var.github_token
  organization = var.github_organization
}

resource "github_repository" "main" {
  name        = var.repo_name
  description = "Cluster repository"
  private     = true
  auto_init   = true
}

