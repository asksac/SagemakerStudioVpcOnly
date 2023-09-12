aws_profile                 = "terraform_2599" 
aws_region                  = "us-east-1"
aws_org_id                  = "o-6cm254hawu" # Organization ID of this account
app_name                    = "SagemakerStudioVpcOnly"
app_shortcode               = "SSVPC"

vpc_id                      = "vpc-0926cf66eb5897d56" # "vpc-7eb0f404"
subnet_ids                  = [ "subnet-0229f4fcd9b00c1c5", "subnet-03b652b9ab3c22192" ] # [ "subnet-f54d7bdb", "subnet-fd9d66b0", "subnet-a04276fc" ]
ss_domain_name              = "ssvpc-use1-studio-domain"

# list of available notebook images for each region: https://docs.aws.amazon.com/sagemaker/latest/dg/notebooks-available-images.html
ss_notebook_image_arn       = "arn:aws:sagemaker:us-east-1:081325390199:image/sagemaker-data-science-310-v1"

enable_ssm                  = false
create_ec2                  = false
