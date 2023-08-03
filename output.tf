output "ss_bucket_arn" {
  value                     = aws_s3_bucket.ss_bucket.arn
}

output "ss_exec_role_arn" {
  value                     = aws_iam_role.ss_exec_role.arn
}

output "aws_s3_key" {
  value                     = data.aws_kms_key.aws_s3_key.arn
}

output "vpc_id" {
  value                     = data.aws_vpc.given.id 
}

output "subnet_ids" {
  value                     = data.aws_subnet.given.*.id
}

output "ss_security_group_id" {
  value                     = aws_security_group.sagemaker_sg.id
}

