/*

# steps to manually delete a SageMaker Studio Domain and all associated apps and user-profiles

export SS_REGION=us-east-1

aws --region $SS_REGION sagemaker list-domains

aws --region $SS_REGION sagemaker list-apps --domain-id d-x5g4mdrcd7js

aws --region $SS_REGION sagemaker delete-app --domain-id d-x5g4mdrcd7js \
  --app-name "datascience-1-0-ml-t3-medium-1abf3407f667f989be9d86559395" \
  --app-type KernelGateway \
  --user-profile-name default-1611290129086

aws --region $SS_REGION sagemaker delete-app --domain-id d-x5g4mdrcd7js \
  --app-name "default" \
  --app-type JupyterServer \
  --user-profile-name default-1611290129086

aws --region $SS_REGION sagemaker list-user-profiles --domain-id d-x5g4mdrcd7js

aws --region $SS_REGION sagemaker delete-user-profile --domain-id d-x5g4mdrcd7js \
  --user-profile-name "default-1611290129086"

aws --region $SS_REGION sagemaker delete-domain --domain-id d-x5g4mdrcd7js \
  --retention-policy HomeEfsFileSystem=Delete

*/

## SageMaker Studio


resource "aws_sagemaker_domain" "sagemaker_studio_domain" {
  domain_name               = var.ss_domain_name
  auth_mode                 = "IAM"
  vpc_id                    = data.aws_vpc.given.id 
  subnet_ids                = var.subnet_ids 

  app_network_access_type   = "VpcOnly"

  # key used to encrypt studio domain's EFS volume
  kms_key_id                = aws_kms_key.ss_efs_key.arn

  retention_policy {
    home_efs_file_system    = "Retain" # or "Delete"
  }

  default_space_settings {
    execution_role          = aws_iam_role.ss_exec_role.arn
    security_groups         = [ aws_security_group.sagemaker_sg.id ]
  }
  default_user_settings {
    execution_role          = aws_iam_role.ss_exec_role.arn
    security_groups         = [ aws_security_group.sagemaker_sg.id ]

    canvas_app_settings {
      workspace_settings {
        s3_artifact_path    = "s3://${aws_s3_bucket.ss_bucket.id}/canvas/"
      }
    }

    jupyter_server_app_settings {
      default_resource_spec {
        instance_type       = "system" # must be system
      }
    }

    kernel_gateway_app_settings {
      default_resource_spec {
        instance_type       = "ml.t3.medium" # "system"
        sagemaker_image_arn = var.ss_notebook_image_arn
      }
    }

    sharing_settings {
      notebook_output_option  = "Allowed"
      s3_output_path          = "s3://${aws_s3_bucket.ss_bucket.id}/notebook-sharing/"
    }
  }
}

/*
Reference: https://docs.aws.amazon.com/whitepapers/latest/sagemaker-studio-admin-best-practices/identity-management.html 

TODO: configure IAM policy to restrict access to only designated user profile
*/
resource "aws_sagemaker_user_profile" "ss_default_user" {
  domain_id                 = aws_sagemaker_domain.sagemaker_studio_domain.id
  user_profile_name         = "default-user"

  user_settings {
    # keeping the same execution role as the studio domain
    execution_role          = aws_iam_role.ss_exec_role.arn
  }
}

/*
References: 
Dive deep into Amazon SageMaker Studio Notebooks architecture: 
https://aws.amazon.com/blogs/machine-learning/dive-deep-into-amazon-sagemaker-studio-notebook-architecture/

*/


# JupyterServer – The JupyterServer app runs the Jupyter server. Each user has a unique and 
# dedicated JupyterServer app running inside the studio domain.
resource "aws_sagemaker_app" "ss_jupyter_server_app" {
  domain_id                 = aws_sagemaker_domain.sagemaker_studio_domain.id
  user_profile_name         = aws_sagemaker_user_profile.ss_default_user.user_profile_name

  # keep app_name as `default` to prevent Studio from launching its own JupyterServer app instance
  app_name                  = "default" # must keep as default
  app_type                  = "JupyterServer"

  depends_on                = [ aws_sagemaker_user_profile.ss_default_user ]
}

# KernelGateway – The KernelGateway app corresponds to a running SageMaker image container. 
# Each user can have multiple KernelGateway apps running at a time in a single studio domain.
resource "aws_sagemaker_app" "ss_kernel_gateway_app" {
  domain_id                 = aws_sagemaker_domain.sagemaker_studio_domain.id
  user_profile_name         = aws_sagemaker_user_profile.ss_default_user.user_profile_name

  app_name                  = "default-ml-t3-medium"
  app_type                  = "KernelGateway" 

  resource_spec {
    instance_type           = "ml.t3.medium" # default fast start 
    sagemaker_image_arn     = var.ss_notebook_image_arn
  }

  depends_on                = [ aws_sagemaker_user_profile.ss_default_user ]
}
