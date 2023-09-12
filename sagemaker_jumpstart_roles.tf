/*

The following 9 roles are used by SageMaker Jumpstart to launch various solutions. 
We will not rely on SageMaker to create these roles when a new Studio Domain is created. 
Instead, we will create these roles with customized inline policies here. 

More details: 
https://docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-solutions-launch.html
https://docs.aws.amazon.com/sagemaker/latest/dg/security-iam-awsmanpol-sc.html 

Default service role names: 
1. API Gateway – AmazonSageMakerServiceCatalogProductsApiGatewayRole
2. CloudFormation – AmazonSageMakerServiceCatalogProductsCloudformationRole
3. CodeBuild – AmazonSageMakerServiceCatalogProductsCodeBuildRole
4. CodePipeline – AmazonSageMakerServiceCatalogProductsCodePipelineRole
5. Events – AmazonSageMakerServiceCatalogProductsEventsRole
6. Firehose – AmazonSageMakerServiceCatalogProductsFirehoseRole
7. Glue – AmazonSageMakerServiceCatalogProductsGlueRole
8. Lambda – AmazonSageMakerServiceCatalogProductsLambdaRole
9. SageMaker – AmazonSageMakerServiceCatalogProductsExecutionRole

Managed policies: 
1. AWS managed policy reference: AmazonSageMakerServiceCatalogProductsApiGatewayServiceRolePolicy
2. AWS managed policy reference: AmazonSageMakerServiceCatalogProductsCloudformationServiceRolePolicy
3. AWS managed policy reference: AmazonSageMakerServiceCatalogProductsCodeBuildServiceRolePolicy
4. AWS managed policy reference: AmazonSageMakerServiceCatalogProductsCodePipelineServiceRolePolicy
5. AWS managed policy reference: AmazonSageMakerServiceCatalogProductsEventsServiceRolePolicy
6. AWS managed policy reference: AmazonSageMakerServiceCatalogProductsFirehoseServiceRolePolicy
7. AWS managed policy reference: AmazonSageMakerServiceCatalogProductsGlueServiceRolePolicy
8. AWS managed policy reference: AmazonSageMakerServiceCatalogProductsLambdaServiceRolePolicy
9. AWS managed policy: AmazonSageMakerFullAccess

*/

locals {
  sp_role_map = {
    servicecatalog = {
      role_name = "AmazonSageMakerServiceCatalogProductsLaunchRole"
      managed_policy_names = ["AmazonSageMakerAdmin-ServiceCatalogProductsServiceRolePolicy"]
    }
    apigateway = {
      role_name = "AmazonSageMakerServiceCatalogProductsApiGatewayRole"
      managed_policy_names = ["AmazonSageMakerServiceCatalogProductsApiGatewayServiceRolePolicy"]
    }
    cloudformation = {
      role_name = "AmazonSageMakerServiceCatalogProductsCloudformationRole"
      managed_policy_names = ["AmazonSageMakerServiceCatalogProductsCloudformationServiceRolePolicy"]
    }
    codebuild = {
      role_name = "AmazonSageMakerServiceCatalogProductsCodeBuildRole"
      managed_policy_names = ["AmazonSageMakerServiceCatalogProductsCodeBuildServiceRolePolicy"]
    }
    codepipeline = {
      role_name = "AmazonSageMakerServiceCatalogProductsCodePipelineRole"
      managed_policy_names = ["AmazonSageMakerServiceCatalogProductsCodePipelineServiceRolePolicy"]
    }
    events = {
      role_name = "AmazonSageMakerServiceCatalogProductsEventsRole"
      managed_policy_names = ["AmazonSageMakerServiceCatalogProductsEventsServiceRolePolicy"]
    }
    firehose = {
      role_name = "AmazonSageMakerServiceCatalogProductsFirehoseRole"
      managed_policy_names = ["AmazonSageMakerServiceCatalogProductsFirehoseServiceRolePolicy"]
    }
    glue = {
      role_name = "AmazonSageMakerServiceCatalogProductsGlueRole"
      managed_policy_names = ["AmazonSageMakerServiceCatalogProductsGlueServiceRolePolicy"]
    }
    lambda = {
      role_name = "AmazonSageMakerServiceCatalogProductsLambdaRole"
      managed_policy_names = ["AmazonSageMakerServiceCatalogProductsLambdaServiceRolePolicy"]
    }
    sagemaker = {
      role_name = "AmazonSageMakerServiceCatalogProductsExecutionRole"
      managed_policy_names = ["AmazonSageMakerFullAccess"]
    }
  }
}

data "aws_iam_policy_document" "sagemaker_sc_roles_assume_policy" {
  for_each              = local.sp_role_map
  statement {
    actions             = ["sts:AssumeRole"]

    principals {
      type              = "Service"
      identifiers       = ["${each.key}.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "sagemaker_sc_roles_managed_policy" {
  for_each              = toset(flatten([for v in values(local.sp_role_map): v.managed_policy_names]))
  name                  = each.value
}

resource "aws_iam_role" "sagemaker_sc_product_roles" {
  for_each              = local.sp_role_map

  name                  = each.value.role_name
  path                  = "/service-role/"

  assume_role_policy    = data.aws_iam_policy_document.sagemaker_sc_roles_assume_policy[each.key].json
  managed_policy_arns   = [ for mp in each.value.managed_policy_names: data.aws_iam_policy.sagemaker_sc_roles_managed_policy[mp].arn ]
}
