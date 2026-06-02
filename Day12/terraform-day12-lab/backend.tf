terraform {
  backend "s3" {
    bucket         = "priya-day12-tf-state-02062026"
    key            = "day12/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "priya-day12-terraform-locks"
    encrypt        = true
  }
}