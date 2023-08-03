data "aws_caller_identity" "current" {}

locals {
  # Common tags to be assigned to all resources
  common_tags             = {
    Application           = var.app_name
    Environment           = var.aws_env
  }

  account_id              = data.aws_caller_identity.current.account_id
}
