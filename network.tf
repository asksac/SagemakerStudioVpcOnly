resource "aws_flow_log" "ss_vpc_flow_log" {
  vpc_id                    = data.aws_vpc.given.id

  traffic_type              = "ALL"
  iam_role_arn              = aws_iam_role.vfl_exec_role.arn
  log_destination           = aws_cloudwatch_log_group.vfl_log_group.arn

  tags                      = {
    Name = "${var.app_shortcode}_vpc_flow_log"
  }
}


# Create a log group for storing VPC flow logs
resource "aws_cloudwatch_log_group" "vfl_log_group" {
  name                      = "/aws/vpc-flowlogs/${data.aws_vpc.given.id}"
  retention_in_days         = 30 
}

# Create an IAM role, giving permissions to access CloudWatch Logs

resource "aws_iam_role" "vfl_exec_role" {
  name                      = "${var.app_shortcode}_VPC_Flow_Logs_Exec_Role"
  assume_role_policy        = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
      "Action": [
        "sts:AssumeRole"
      ],
      "Principal": {
          "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "VpcFlowLogsAssumeRolePolicy"
      }
  ]
}
EOF
}

resource "aws_iam_policy" "vfl_exec_role_policy" {
  name                      = "${var.app_shortcode}_VPC_Flow_Logs_Role_Policy"
  path                      = "/"
  description               = "IAM policy with permissions to access CloudWatch Logs"

  policy                    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents", 
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Resource": "arn:aws:logs:*:*:log-group:/aws/vpc-flowlogs/*",
      "Effect": "Allow"
    } 
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "vfl_policy_attach" {
  role                      = aws_iam_role.vfl_exec_role.name
  policy_arn                = aws_iam_policy.vfl_exec_role_policy.arn
}

