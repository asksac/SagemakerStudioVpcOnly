# Access SageMaker Studio and SageMaker JumpStart through a VPC

## Overview 

This project shows how to setup and configure a SageMaker Studio Domain in VpcOnly mode, and enable
access to SageMaker JumpStart for Domain users via Terraform automation. 

## Diagram

![SageMaker Studio VPC architecture diagram](/docs/images/SageMaker_Studio_Jumpstart_VPC_Pattern.png)

## Installation

This project uses Terraform to deploy the SageMaker infrastructure. 
### 1. Customize variable values 

The Terraform configuration in this project defines several input variables 
that must be set based on your environment before you can deploy the configuration. 
You may set input values using a `module` configuration block from your own Terraform 
project. Or, you may run this project as a root module directly, and set input values in 
a file named `terraform.tfvars` in the project's root directory. An example `terraform.tfvars` 
might look like this: 

```
aws_profile                 = "default" 
aws_region                  = "us-east-1"
app_name                    = "SagemakerStudioVpcOnly"
app_shortcode               = "SSVPC"
vpc_id                      = "vpc-0a2b3c4d5e6f" 
subnet_ids                  = [ "subnet-9876fedc543ba", "subnet-0f2e3d4c5b6a1" ] 
ss_domain_name              = "ssvpc-use1-studio-domain"

# list of available notebook images for each region: https://docs.aws.amazon.com/sagemaker/latest/dg/notebooks-available-images.html
ss_notebook_image_arn       = "arn:aws:sagemaker:us-east-1:081325390199:image/sagemaker-data-science-310-v1"
```

*For your testing, make sure to change above values based on your environment setup. 

### 2. Apply Terraform configuration

You're now ready for installation, which is to deploy the Terraform configuration. Run the 
following commands in a Terminal from the project root directory:

```shell
terraform init
terraform apply
```

Second command above will first run _plan_ phase of Terraform, and output a list of 
resources that Terraform will create. After verifying, enter `yes` to proceed with resource 
creation. This step may take a few minutes to complete. At the end, it will output a couple of  
configuration values that must be noted for testing and validation steps (next section). 


## Accessing SageMaker Studio

To access SageMaker Studio deployed via this project, you need a web browser. You can launch Studio either
through AWS Management Console, or using command line (requires aws cli to be installed). 

To generate a pre-signed URL for the domain, run the following command: 

#### For _default-user_ profile: 

```shell
aws lambda invoke --function-name StudioPURL /dev/stdout
```

#### For all other user profiles: 

```shell
aws lambda invoke --function-name StudioPURL --payload '{"profile_name": "name-of-profile-here"}' --cli-binary-format raw-in-base64-out /dev/stdout
```

Copy the URL returned in the Location field of the output JSON, and paste it into a web-browser to launch SageMaker Studio. 

## License

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

- **[MIT license](http://opensource.org/licenses/mit-license.php)**
- Copyright 2023 &copy; Sachin Hamirwasia

