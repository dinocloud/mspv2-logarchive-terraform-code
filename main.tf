locals {
  common_name = lower("${var.customer}-${var.team}-${var.component}-infra-${var.environment}")
  #Tags
  common_tags = {
    Project     = var.component
    Customer    = var.customer
    Team        = var.team
    CostCenter  = var.team
    Environment = var.environment
    Provisioner = "terraform"
    Common_name = local.common_name
  }
}

module "" {
  source  = ""
  version = ""
  name    = local.common_name
  tags    = local.common_tags
}
