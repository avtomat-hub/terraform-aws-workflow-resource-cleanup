provider "aws" {
  alias  = "spoke-111111111111"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::111111111111:role/ExampleRole"
  }

  default_tags {
    tags = {
      managed_by = "terraform"
    }
  }
}

provider "aws" {
  alias  = "spoke-222222222222"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::222222222222:role/ExampleRole"
  }

  default_tags {
    tags = {
      managed_by = "terraform"
    }
  }
}