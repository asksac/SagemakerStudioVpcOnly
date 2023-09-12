variable "aws_profile" {
  type                    = string
  default                 = "default"
  description             = "Specify an aws profile name to be used for access credentials (run `aws configure help` for more information on creating a new profile)"
}

variable "aws_region" {
  type                    = string
  default                 = "us-east-1"
  description             = "Specify the AWS region to be used for deploying resources"
}

variable "aws_env" {
  type                    = string
  default                 = "dev"
  description             = "Specify a value for the Environment tag"
}

variable "app_name" {
  type                    = string
  default                 = "SagemakerStudioVpcOnly"
  description             = "Specify an application or project name, used primarily for tagging"
}

variable "app_shortcode" {
  type                    = string
  default                 = "SSVPC"
  description             = "Specify a short-code or pneumonic for this application or project, used in naming resources"
}

variable "aws_org_id" {
  type                    = string
  description             = "Specify the Organization ID this account belongs to; will be used in identity policies (ResourceOrgId) and resource policies (PrincipalOrgId)"
}

variable "vpc_id" {
  type                    = string
  description             = "Specify an existing VPC ID to use for resources and endpoints"
}

variable "subnet_ids" {
  type                    = list 
  description             = "Specify a list of valid Subnet IDs where ENIs will be created"
}

variable "ss_domain_name" {
  type                    = string
  default                 = "my-studio-vpconly"
  description             = "Specify name to be used for Sagemaker Studio Domain"
}

variable "ss_notebook_image_arn" {
  type                    = string
  description             = "Specify the arn of a valid jupyter lab notebook image"
}

variable "create_ec2" {
  type                    = bool
  default                 = false
  description             = "Specify whether to create a test EC2 instance in the VPC"
}

variable "enable_ssm" {
  type                    = bool
  default                 = false
  description             = "Specify whether to enable SSM Session Manager for EC2; if enabled, create SSM VPC endpoints"
}

