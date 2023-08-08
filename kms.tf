# create a kms key for SageMaker Studio Domain EFS volume encryption 
resource "aws_kms_key" "ss_efs_key" {
  deletion_window_in_days = 7 # waiting period to purge key material after key is deleted
  description             = "${var.app_name} - SageMaker Studio Domain EFS Encryption Key"
}


# create a kms key for CodeArtifact domain encryption 
resource "aws_kms_key" "ca_domain_key" {
  deletion_window_in_days = 7 # waiting period to purge key material after key is deleted
  description             = "${var.app_name} - CodeArtifact Domain Encryption Key"
}

