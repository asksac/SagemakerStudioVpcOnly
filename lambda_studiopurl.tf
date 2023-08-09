locals {
  lambda_name                 = "StudioPURL"
}

# ---
# create a security group for lambda deployed inside a vpc
# 
resource "aws_security_group" "lambda_vpc_sg" {
  name                        = "${var.app_shortcode}_lambda_sg"
  vpc_id                      = data.aws_vpc.given.id

  ingress {
    cidr_blocks               = [ data.aws_vpc.given.cidr_block ]
    from_port                 = 443
    to_port                   = 443
    protocol                  = "tcp"
  }

  egress {
    cidr_blocks               = [ data.aws_vpc.given.cidr_block ]
    from_port                 = 443
    to_port                   = 443
    protocol                  = "tcp"
  }
}

# ---
# create Lambda execution IAM role, giving permissions to access other AWS services
#
resource "aws_iam_role" "lambda_exec_role" {
  name                = "${var.app_shortcode}_Lambda_Exec_Role"
  assume_role_policy  = jsonencode({
    Version         = "2012-10-17"
    Statement       = [
      {
        Action      = [ "sts:AssumeRole" ]
        Principal   = {
            "Service": "lambda.amazonaws.com"
        }
        Effect      = "Allow"
        Sid         = "LambdaAssumeRolePolicy"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name        = "${var.app_shortcode}_Lambda_Policy"
  path        = "/"
  description = "IAM policy with minimum permissions for Lambda function execution"

  policy = jsonencode({
    Version         = "2012-10-17"
    Statement       = [
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
        Resource    = "arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:/aws/lambda/*:*"
        Effect      = "Allow"
        Sid         = "AllowCloudWatchPutLogEvents"
      }, 
      {
        Action      = [
          "sagemaker:CreatePresignedDomainUrl",
        ]
        Resource    = "*"
        Effect      = "Allow"
        Sid         = "AllowSagemakerAPIAccess"
      }, 
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
}

# ---
# create cloudwatch log group for lambda
#
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = 14
}

# ---
# Upload and create Lambda function
#

data "archive_file" "lambda_archive" {
  source_dir                = "${path.module}/lambdas/studiopurl/src"
  output_file_mode          = "0755"
  output_path               = "${path.module}/dist/${local.lambda_name}_package.zip"
  type                      = "zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name    = local.lambda_name 

  handler          = "main.lambda_handler"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "python3.7"
  timeout          = 60

  filename         = data.archive_file.lambda_archive.output_path
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256

  environment {
    variables = {
      STUDIO_DOMAIN_ID  = aws_sagemaker_domain.sagemaker_studio_domain.id
    }
  }
}
