# Security Group for VPC Endpoints

resource "aws_security_group" "endpoint_sg" {
  name                        = "${var.app_shortcode}_endpoint_sg"
  vpc_id                      = data.aws_vpc.given.id

  ingress {
    cidr_blocks               = [ data.aws_vpc.given.cidr_block ]
    from_port                 = 443
    to_port                   = 443
    protocol                  = "tcp"
  }
}

resource "aws_vpc_endpoint" "vpce_s3_gateway" {
  service_name          = "com.amazonaws.${var.aws_region}.s3"
  vpc_id                = var.vpc_id
  route_table_ids       = data.aws_route_tables.vpc_rts.ids

  auto_accept           = true
  vpc_endpoint_type     = "Gateway"

  policy                = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "FullAccess"
        Principal = "*"
        Action = [
          "*",
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ] 
  })

  tags                  = {
    Name = "${var.app_shortcode}_s3"
  }
}

/*
resource "aws_vpc_endpoint" "vpce_s3_interface" {
  service_name          = "com.amazonaws.${var.aws_region}.s3"
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids

  auto_accept           = true
  vpc_endpoint_type     = "Interface"

  security_group_ids    = [ aws_security_group.endpoint_sg.id ]

  policy                = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "FullAccess"
        Principal = "*"
        Action = [
          "*",
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]        
  })

  tags                  = {
    Name = "${var.app_shortcode}_s3_interface"
  }
}
*/

resource "aws_vpc_endpoint" "vpce_cw_logs" {
  service_name          = "com.amazonaws.${var.aws_region}.logs"
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  private_dns_enabled   = true

  auto_accept           = true
  vpc_endpoint_type     = "Interface"

  security_group_ids    = [ aws_security_group.endpoint_sg.id ]

  policy                = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "SSMRequiredPermissions"
        Principal = "*"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]        
  })

  tags                  = {
    Name = "${var.app_shortcode}_cw_logs"
  }
}

resource "aws_vpc_endpoint" "vpce_sagemaker_api" {
  service_name          = "com.amazonaws.${var.aws_region}.sagemaker.api"
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  security_group_ids    = [ aws_security_group.endpoint_sg.id ]
  private_dns_enabled   = true

  auto_accept           = true
  vpc_endpoint_type     = "Interface"

  policy                = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "FullAccess"
        Principal = "*"
        Action = [
          "*",
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]        
  })

  tags                  = {
    Name = "${var.app_shortcode}_sagemaker_api"
  }
}

resource "aws_vpc_endpoint" "vpce_sagemaker_runtime" {
  service_name          = "com.amazonaws.${var.aws_region}.sagemaker.runtime"
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  security_group_ids    = [ aws_security_group.endpoint_sg.id ]
  private_dns_enabled   = true

  auto_accept           = true
  vpc_endpoint_type     = "Interface"

  policy                = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "FullAccess"
        Principal = "*"
        Action = [
          "*",
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]        
  })

  tags                  = {
    Name = "${var.app_shortcode}_sagemaker_runtime"
  }
}

# sagemaker studio vpc endpoint is needed to allow access to studio via vpc
# more details: https://docs.aws.amazon.com/sagemaker/latest/dg/studio-interface-endpoint.html
resource "aws_vpc_endpoint" "vpce_sagemaker_studio" {
  service_name          = "aws.sagemaker.${var.aws_region}.studio"
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  security_group_ids    = [ aws_security_group.endpoint_sg.id ]
  private_dns_enabled   = true

  auto_accept           = true
  vpc_endpoint_type     = "Interface"

  policy                = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "FullAccess"
        Principal = "*"
        Action = [
          "sagemaker:CreateApp",
        ]
        Effect = "Allow"
        Resource = "arn:aws:sagemaker:${var.aws_region}:${local.account_id}:app/domain-id/*"
      },
    ]        
  })

  tags                  = {
    Name = "${var.app_shortcode}_sagemaker_studio"
  }
}

# vpc endpoint to sts is needed by several sagemaker jumpstart projects
resource "aws_vpc_endpoint" "vpce_sts" {
  service_name          = "com.amazonaws.${var.aws_region}.sts"
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  security_group_ids    = [ aws_security_group.endpoint_sg.id ]
  private_dns_enabled   = true

  auto_accept           = true
  vpc_endpoint_type     = "Interface"

  policy                = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "FullAccess"
        Principal = "*"
        Action = [
          "*",
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]        
  })

  tags                  = {
    Name = "${var.app_shortcode}_sts"
  }
}

# vpc endpoint to service catalog is needed to access sagemaker projects and jumpstart
resource "aws_vpc_endpoint" "vpce_service_catalog" {
  service_name          = "com.amazonaws.${var.aws_region}.servicecatalog"
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  security_group_ids    = [ aws_security_group.endpoint_sg.id ]
  private_dns_enabled   = true

  auto_accept           = true
  vpc_endpoint_type     = "Interface"

  policy                = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "FullAccess"
        Principal = "*"
        Action = [
          "*",
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]        
  })

  tags                  = {
    Name = "${var.app_shortcode}_service_catalog"
  }
}

# EC2 vcp endpoint enables 'Find VPC' option in Studio UI
resource "aws_vpc_endpoint" "vpce_ec2" {
  service_name          = "com.amazonaws.${var.aws_region}.ec2"
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  private_dns_enabled   = true

  auto_accept           = true
  vpc_endpoint_type     = "Interface"

  security_group_ids    = [ aws_security_group.endpoint_sg.id ]

  policy                = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "EC2RequiredPermissions"
        Principal = "*"
        Action = [
          "ec2:Describe*",
          "ec2:Get*",
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]        
  })

  tags                  = {
    Name = "${var.app_shortcode}_ec2"
  }
}
