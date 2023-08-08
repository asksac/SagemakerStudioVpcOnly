# Security Group for Sagemaker Studio Apps

resource "aws_security_group" "sagemaker_sg" {
  name                        = "${var.app_shortcode}_sagemaker_sg"
  vpc_id                      = data.aws_vpc.given.id

  ingress {
    from_port                 = 0
    to_port                   = 0
    protocol                  = "-1"
    #cidr_blocks               = [ data.aws_vpc.given.cidr_block ]
    self                      = true
  }

  # egress to all ports within VPC CIDR is needed to enable communication between studio and kernel apps
  egress {
    from_port           = 0
    to_port             = 0
    protocol            = -1
    cidr_blocks         = [ data.aws_vpc.given.cidr_block ]
  }

  # allow egress to 443 on S3 gateway endpoint prefix list
  egress {
    from_port           = 443
    to_port             = 443
    protocol            = "tcp"
    prefix_list_ids     = [ aws_vpc_endpoint.vpce_s3_gateway.prefix_list_id ]
  }
}

# IAM execution role for Sagemaker Studio Users

resource "aws_iam_role" "ss_exec_role" {
  name                      = "${var.ss_domain_name}-execution-role" 
  path                      = "/"
  assume_role_policy        = data.aws_iam_policy_document.ss_assume_role_policy.json
}

data "aws_iam_policy_document" "ss_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ss_exec_policy" {
  name                      = "${var.ss_domain_name}-execution-policy"
  path                      = "/"
  description               = "IAM policy with permissions for ${var.ss_domain_name} Sagemaker Studio Domain"

  policy                    = jsonencode({
    Version         = "2012-10-17"
    Statement       = [
      {
        Action      = [
          "iam:PassRole",
        ]
        Resource    = "*"
        Effect      = "Allow"
        Sid         = "AllowIamPassRole"
      }, 
      {
        Action      = [
          "ec2:*",
        ]
        Resource    = "*"
        Effect      = "Allow"
        Sid         = "AllowFullEC2Access"
      }, 
      {
        "Effect": "Allow",
        "Action": [
          "kms:Encrypt", 
          "kms:Decrypt", 
          "kms:CreateGrant", 
          "kms:DescribeKey", 
          "kms:ListKeys", 
        ]
        Resource    = "*"
        Effect      = "Allow"
        Sid         = "AllowKMSAccess"
      }, 
      {
        Action      = [
          "logs:CreateLogGroup",
        ]
        Resource    = "arn:aws:logs:${var.aws_region}:${local.account_id}:*"
        Effect      = "Allow"
        Sid         = "AllowCloudWatchLogsAccess"
      }, 
      {
        Action      = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource    = "arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:*:*"
        Effect      = "Allow"
        Sid         = "AllowCloudWatchPutLogEvents"
      }, 
      {
        Action      = [
          "s3:Get*",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
        ]
        Resource    = "arn:aws:s3:::*"
        Effect      = "Allow"
        Sid         = "AllowS3ReadWriteAccess"
      }, 
      # required for SageMaker JumpStart
      {
        Effect      = "Allow",
        Action      = [
            "servicecatalog:ProvisionProduct"
        ],
        Resource    = "*"
      },      
      {
        Effect      = "Allow",
        Action      = "codeartifact:GetAuthorizationToken",
        Resource    = aws_codeartifact_domain.main.arn # "arn:aws:codeartifact:<region>:<account_no>:domain/<domain_name>"
      },
      {
        Effect      = "Allow",
        Action      = "sts:GetServiceBearerToken",
        Resource    = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ss_exec_policy_attachment" {
  role                      = aws_iam_role.ss_exec_role.name
  policy_arn                = aws_iam_policy.ss_exec_policy.arn
}


# Attach AmazonSageMakerFullAccess to Studio Execution Role 
data "aws_iam_policy" "sagemaker_managed_policy" {
  name                      = "AmazonSageMakerFullAccess"
}

resource "aws_iam_role_policy_attachment" "ss_exec_managed_policy_attachment_1" {
  role                      = aws_iam_role.ss_exec_role.name
  policy_arn                = data.aws_iam_policy.sagemaker_managed_policy.arn
}

# Attach AmazonSageMakerCanvasFullAccess and AmazonSageMakerCanvasAIServicesAccess
# managed policies to enable support for Canvas in SageMaker Studio 
data "aws_iam_policy" "sagemaker_canvas_managed_policy" {
  name                      = "AmazonSageMakerCanvasFullAccess"
}

resource "aws_iam_role_policy_attachment" "ss_exec_managed_policy_attachment_2" {
  role                      = aws_iam_role.ss_exec_role.name
  policy_arn                = data.aws_iam_policy.sagemaker_canvas_managed_policy.arn
}

data "aws_iam_policy" "sagemaker_canvas_ai_managed_policy" {
  name                      = "AmazonSageMakerCanvasAIServicesAccess"
}

resource "aws_iam_role_policy_attachment" "ss_exec_managed_policy_attachment_3" {
  role                      = aws_iam_role.ss_exec_role.name
  policy_arn                = data.aws_iam_policy.sagemaker_canvas_ai_managed_policy.arn
}

