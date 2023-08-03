## VPC Endpoint to AWS Services required by SSM Session Manager ##

# com.amazonaws.region.ssm: The endpoint for the Systems Manager service
resource "aws_vpc_endpoint" "vpce_ssm" {
  count                 = var.create_ec2 && var.enable_ssm ? 1 : 0

  service_name          = "com.amazonaws.${var.aws_region}.ssm"

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
          "ssm:UpdateInstanceInformation",
          "ssm:ListInstanceAssociations", 
          "ssm:DescribeInstanceProperties", 
          "ssm:DescribeDocumentParameters", 
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]        
  })

  tags                  = {
    Name = "${var.app_shortcode}_ssm"
  }
}

# com.amazonaws.region.ec2messages: Systems Manager uses this endpoint to make calls from SSM Agent to the Systems Manager service
resource "aws_vpc_endpoint" "vpce_ec2_messages" {
  count                 = var.create_ec2 && var.enable_ssm ? 1 : 0

  service_name          = "com.amazonaws.${var.aws_region}.ec2messages"
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
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply",
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]        
  })

  tags                  = {
    Name = "${var.app_shortcode}_ec2_messages"
  }
}

# com.amazonaws.region.ssmmessages: This endpoint is required to connect to your instances through a secure data channel using Session Manager 
resource "aws_vpc_endpoint" "vpce_ssm_messages" {
  count                 = var.create_ec2 && var.enable_ssm ? 1 : 0

  service_name          = "com.amazonaws.${var.aws_region}.ssmmessages"
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
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]        
  })

  tags                  = {
    Name = "${var.app_shortcode}_ssm_messages"
  }
}
