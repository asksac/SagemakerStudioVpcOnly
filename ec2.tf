## Security group for EC2 instance

resource "aws_security_group" "ec2_sg" {
  count                 = var.create_ec2 ? 1 : 0

  name                  = "${var.app_shortcode}_ec2_sg"
  vpc_id                = data.aws_vpc.given.id

  # no ingress rules are needed to enble SSM session manager access

  # allow egress to 443 on VPC CIDR to enable traffic to VPC interface endpoints
  egress {
    from_port           = 443
    to_port             = 443
    protocol            = "tcp"
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

## EC2 Instance Profile and Execution Role ## 

resource "aws_iam_role" "ec2_ssm_exec_role" {
  count                 = var.create_ec2 ? 1 : 0

  name                  = "${var.app_shortcode}-ec2-ssm-exec-role"
  assume_role_policy    = jsonencode({
    Version           = "2012-10-17"
    Statement         = [
      {
        Action        = "sts:AssumeRole"
        Principal     = {
          Service     = [
            "ec2.amazonaws.com"
          ]
        }
        Effect        = "Allow"
        Sid           = "EC2ExecRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_ssm_exec_role_permissions" {
  count                 = var.create_ec2 ? 1 : 0

  name_prefix           = "${var.app_shortcode}-ec2-ssm-exec-role-permissions-"
  description           = "Provides EC2 instance access to SSM, S3 and CW Logs services"

  policy                = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "SSMPermissions"
        Action = [
          "ssm:UpdateInstanceInformation",
          "ssm:ListInstanceAssociations", 
          "ssm:DescribeInstanceProperties", 
          "ssm:DescribeDocumentParameters", 
          "ssm:StartSession",
          "ssm:TerminateSession", 
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Sid = "SSMMessagesPermissions"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Sid = "EC2MessagesPermissions"
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
      {
        Sid = "CWLogsPermissions"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Sid = "KMSPermissions"
        Action = [
          "kms:GenerateDataKey",
        ]
        Effect = "Allow"
        Resource = "*"
      },
      {
        Sid = "S3Permissions"
        Action = [
          "s3:GetEncryptionConfiguration",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]        
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_exec_role_policy" {
  count                 = var.create_ec2 ? 1 : 0

  role                  = aws_iam_role.ec2_ssm_exec_role[count.index].name
  policy_arn            = aws_iam_policy.ec2_ssm_exec_role_permissions[count.index].arn
  #policy_arn            = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  count                 = var.create_ec2 ? 1 : 0

  name                  = "${var.app_shortcode}-ec2-instance-profile"
  role                  = aws_iam_role.ec2_ssm_exec_role[count.index].name
}

# get the most recent Amazon Linux 2 AMI
data "aws_ami" "ec2_ami" {
  most_recent           = true
  owners                = ["amazon"]

  filter {
    name                = "name"
    values              = ["amzn2-ami-hvm-2*"]
  }

  filter {
    name                = "architecture"
    values              = ["x86_64"]
  }

  filter {
    name                = "root-device-type"
    values              = ["ebs"]
  }

  filter {
    name                = "virtualization-type"
    values              = ["hvm"]
  }
}

# create a test ec2 instance 
resource "aws_instance" "test_instance" {
  count                 = var.create_ec2 ? 1 : 0

  ami                   = data.aws_ami.ec2_ami.id
  instance_type         = "t3.small"

  subnet_id             = var.subnet_ids[0]

  vpc_security_group_ids  = [ aws_security_group.ec2_sg[count.index].id ]
  iam_instance_profile    = aws_iam_instance_profile.ec2_instance_profile[count.index].name

  tags                  = {
    Name = "${var.app_shortcode}_test_ec2"
  }
}

