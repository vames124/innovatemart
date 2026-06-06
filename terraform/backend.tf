terraform {
  backend "s3" {
    bucket       = "project-bedrock-tfstate-alt-soe-025-4486"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
