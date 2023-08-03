data "aws_vpc" "given" {
  id                      = var.vpc_id
}

data "aws_subnet" "given" {
  count                   = length(var.subnet_ids)
  id                      = var.subnet_ids[count.index]
}

data "aws_route_tables" "vpc_rts" {
  vpc_id                  = var.vpc_id
}

