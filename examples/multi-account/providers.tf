provider "aws" {
  region = var.region

  default_tags {
    tags = {
      managed_by = "terraform"
    }
  }
}

provider "aws" {
  alias  = "spoke-111111111111"
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::111111111111:role/ExampleRole"
  }

  default_tags {
    tags = {
      managed_by = "terraform"
    }
  }
}