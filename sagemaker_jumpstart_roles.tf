/*

The following 10 roles are used by SageMaker Jumpstart to launch various solutions. 
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

## -------- SageMaker -> Service Catalog

# Adapted from AWS managed policy: AmazonSageMakerAdmin-ServiceCatalogProductsServiceRolePolicy 
# This policy is intended to be used by the AmazonSageMakerServiceCatalogProductsLaunchRole role 
# created from the SageMaker console. The policy adds permissions to provision AWS resources for 
# SageMaker projects and JumpStart using Service Catalog to a customer's account.
data "aws_iam_policy_document" "service_catalog_products_service_role_policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "apigateway:GET",
      "apigateway:POST",
      "apigateway:PUT",
      "apigateway:PATCH",
      "apigateway:DELETE",
    ]

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/sagemaker:launch-source"
      values   = ["*"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["apigateway:POST"]

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:TagKeys"
      values   = ["sagemaker:launch-source"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:apigateway:*::/account"]
    actions   = ["apigateway:PATCH"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:cloudformation:*:*:stack/SC-*"]

    actions = [
      "cloudformation:CreateStack",
      "cloudformation:UpdateStack",
      "cloudformation:DeleteStack",
    ]

    condition {
      test     = "ArnLikeIfExists"
      variable = "cloudformation:RoleArn"
      values   = ["arn:aws:sts::*:assumed-role/AmazonSageMakerServiceCatalog*"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:cloudformation:*:*:stack/SC-*"]

    actions = [
      "cloudformation:DescribeStackEvents",
      "cloudformation:DescribeStacks",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "cloudformation:GetTemplateSummary",
      "cloudformation:ValidateTemplate",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:codebuild:*:*:project/sagemaker-*"]

    actions = [
      "codebuild:CreateProject",
      "codebuild:DeleteProject",
      "codebuild:UpdateProject",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:codecommit:*:*:sagemaker-*"]

    actions = [
      "codecommit:CreateCommit",
      "codecommit:CreateRepository",
      "codecommit:DeleteRepository",
      "codecommit:GetRepository",
      "codecommit:TagResource",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["codecommit:ListRepositories"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:codepipeline:*:*:sagemaker-*"]

    actions = [
      "codepipeline:CreatePipeline",
      "codepipeline:DeletePipeline",
      "codepipeline:GetPipeline",
      "codepipeline:GetPipelineState",
      "codepipeline:StartPipelineExecution",
      "codepipeline:TagResource",
      "codepipeline:UpdatePipeline",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "cognito-idp:CreateUserPool",
      "cognito-idp:TagResource",
    ]

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:TagKeys"
      values   = ["sagemaker:launch-source"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "cognito-idp:CreateGroup",
      "cognito-idp:CreateUserPoolDomain",
      "cognito-idp:CreateUserPoolClient",
      "cognito-idp:DeleteGroup",
      "cognito-idp:DeleteUserPool",
      "cognito-idp:DeleteUserPoolClient",
      "cognito-idp:DeleteUserPoolDomain",
      "cognito-idp:DescribeUserPool",
      "cognito-idp:DescribeUserPoolClient",
      "cognito-idp:UpdateUserPool",
      "cognito-idp:UpdateUserPoolClient",
    ]

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/sagemaker:launch-source"
      values   = ["*"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:ecr:*:*:repository/sagemaker-*"]

    actions = [
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:TagResource",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:events:*:*:rule/sagemaker-*"]

    actions = [
      "events:DescribeRule",
      "events:DeleteRule",
      "events:DisableRule",
      "events:EnableRule",
      "events:PutRule",
      "events:PutTargets",
      "events:RemoveTargets",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:firehose:*:*:deliverystream/sagemaker-*"]

    actions = [
      "firehose:CreateDeliveryStream",
      "firehose:DeleteDeliveryStream",
      "firehose:DescribeDeliveryStream",
      "firehose:StartDeliveryStreamEncryption",
      "firehose:StopDeliveryStreamEncryption",
      "firehose:UpdateDestination",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:glue:*:*:catalog",
      "arn:aws:glue:*:*:database/sagemaker-*",
      "arn:aws:glue:*:*:table/sagemaker-*",
      "arn:aws:glue:*:*:userDefinedFunction/sagemaker-*",
    ]

    actions = [
      "glue:CreateDatabase",
      "glue:DeleteDatabase",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "glue:CreateClassifier",
      "glue:DeleteClassifier",
      "glue:DeleteCrawler",
      "glue:DeleteJob",
      "glue:DeleteTrigger",
      "glue:DeleteWorkflow",
      "glue:StopCrawler",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:glue:*:*:workflow/sagemaker-*"]
    actions   = ["glue:CreateWorkflow"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:glue:*:*:job/sagemaker-*"]
    actions   = ["glue:CreateJob"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:glue:*:*:crawler/sagemaker-*"]

    actions = [
      "glue:CreateCrawler",
      "glue:GetCrawler",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:glue:*:*:trigger/sagemaker-*"]

    actions = [
      "glue:CreateTrigger",
      "glue:GetTrigger",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:iam::*:role/service-role/AmazonSageMakerServiceCatalog*"]
    actions   = ["iam:PassRole"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:lambda:*:*:function:sagemaker-*"]

    actions = [
      "lambda:AddPermission",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:InvokeFunction",
      "lambda:RemovePermission",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:lambda:*:*:function:sagemaker-*"]
    actions   = ["lambda:TagResource"]

    condition {
      test     = "ForAllValues:StringLike"
      variable = "aws:TagKeys"
      values   = ["sagemaker:*"]
    }
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:logs:*:*:log-group:/aws/apigateway/AccessLogs/*",
      "arn:aws:logs:*:*:log-group::log-stream:*",
    ]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogGroup",
      "logs:DeleteLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutRetentionPolicy",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["s3:GetObject"]

    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/servicecatalog:provisioning"
      values   = ["true"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::sagemaker-*"]
    actions   = ["s3:GetObject"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::sagemaker-*"]

    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:DeleteBucketPolicy",
      "s3:GetBucketPolicy",
      "s3:PutBucketAcl",
      "s3:PutBucketNotification",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketLogging",
      "s3:PutEncryptionConfiguration",
      "s3:PutBucketTagging",
      "s3:PutObjectTagging",
      "s3:PutBucketCORS",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:sagemaker:*:*:*"]

    actions = [
      "sagemaker:CreateEndpoint",
      "sagemaker:CreateEndpointConfig",
      "sagemaker:CreateModel",
      "sagemaker:CreateWorkteam",
      "sagemaker:DeleteEndpoint",
      "sagemaker:DeleteEndpointConfig",
      "sagemaker:DeleteModel",
      "sagemaker:DeleteWorkteam",
      "sagemaker:DescribeModel",
      "sagemaker:DescribeEndpointConfig",
      "sagemaker:DescribeEndpoint",
      "sagemaker:DescribeWorkteam",
      "sagemaker:CreateCodeRepository",
      "sagemaker:DescribeCodeRepository",
      "sagemaker:UpdateCodeRepository",
      "sagemaker:DeleteCodeRepository",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:sagemaker:*:*:endpoint/*",
      "arn:aws:sagemaker:*:*:endpoint-config/*",
      "arn:aws:sagemaker:*:*:model/*",
      "arn:aws:sagemaker:*:*:pipeline/*",
      "arn:aws:sagemaker:*:*:project/*",
      "arn:aws:sagemaker:*:*:model-package/*",
    ]

    actions = ["sagemaker:AddTags"]

    condition {
      test     = "ForAllValues:StringLike"
      variable = "aws:TagKeys"
      values   = ["sagemaker:*"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:sagemaker:*:*:image/*"]

    actions = [
      "sagemaker:CreateImage",
      "sagemaker:DeleteImage",
      "sagemaker:DescribeImage",
      "sagemaker:UpdateImage",
      "sagemaker:ListTags",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:states:*:*:stateMachine:sagemaker-*"]

    actions = [
      "states:CreateStateMachine",
      "states:DeleteStateMachine",
      "states:UpdateStateMachine",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:codestar-connections:*:*:connection/*"]
    actions   = ["codestar-connections:PassConnection"]

    condition {
      test     = "StringEquals"
      variable = "codestar-connections:PassedToService"
      values   = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "service_catalog_products_service_assume_role_policy" {
  statement {
    actions             = ["sts:AssumeRole"]

    principals {
      type              = "Service"
      identifiers       = ["servicecatalog.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsLaunchRole" {
  name                  = "AmazonSageMakerServiceCatalogProductsLaunchRole"
  path                  = "/service-role/"
  assume_role_policy    = data.aws_iam_policy_document.service_catalog_products_service_assume_role_policy.json

  inline_policy {
    name                = "service_catalog_products_service_role_policy"
    policy              = data.aws_iam_policy_document.service_catalog_products_service_role_policy.json
  }
}

## -------- SageMaker -> Service Catalog -> API Gateway 

# Adapted from AWS managed policy: AmazonSageMakerServiceCatalogProductsApiGatewayServiceRolePolicy 
# This policy is intended to be used by the AmazonSageMakerServiceCatalogProductsApiGatewayRole role 
# created from the SageMaker console. The policy adds permissions to provision AWS resources for 
# SageMaker projects and JumpStart using Service Catalog to a customer's account.
data "aws_iam_policy_document" "service_catalog_products_api_gateway_role_policy" {
  statement {
    sid       = "AmazonSageMakerServiceCatalogProductsApiGatewayServiceRolePolicy"
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:log-group:/aws/apigateway/*"]

    actions = [
      "logs:CreateLogDelivery",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogDelivery",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DescribeResourcePolicies",
      "logs:DescribeDestinations",
      "logs:DescribeExportTasks",
      "logs:DescribeMetricFilters",
      "logs:DescribeQueries",
      "logs:DescribeQueryDefinitions",
      "logs:DescribeSubscriptionFilters",
      "logs:GetLogDelivery",
      "logs:GetLogEvents",
      "logs:PutLogEvents",
      "logs:PutResourcePolicy",
      "logs:UpdateLogDelivery",
    ]
  }
}

data "aws_iam_policy_document" "service_catalog_products_api_gateway_assume_role_policy" {
  statement {
    actions             = ["sts:AssumeRole"]

    principals {
      type              = "Service"
      identifiers       = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsApiGatewayRole" {
  name                  = "AmazonSageMakerServiceCatalogProductsApiGatewayRole"
  path                  = "/service-role/"
  assume_role_policy    = data.aws_iam_policy_document.service_catalog_products_api_gateway_assume_role_policy.json

  inline_policy {
    name                = "service_catalog_products_service_role_policy"
    policy              = data.aws_iam_policy_document.service_catalog_products_api_gateway_role_policy.json
  }
}

## -------- SageMaker -> Service Catalog -> CloudFormation

# Adapted from AWS managed policy: AmazonSageMakerServiceCatalogProductsCloudformationServiceRolePolicy 
# This policy is intended to be used by the AmazonSageMakerServiceCatalogProductsCloudformationRole role 
# created from the SageMaker console. The policy adds permissions to provision AWS resources for 
# SageMaker projects and JumpStart using Service Catalog to a customer's account.
data "aws_iam_policy_document" "service_catalog_products_cloudformation_role_policy" {
  statement {
    sid    = "AmazonSageMakerServiceCatalogProductsCloudformationServiceRolePolicy"
    effect = "Allow"

    not_resources = [
      "arn:aws:sagemaker:*:*:domain/*",
      "arn:aws:sagemaker:*:*:user-profile/*",
      "arn:aws:sagemaker:*:*:app/*",
      "arn:aws:sagemaker:*:*:flow-definition/*",
    ]

    actions = [
      "sagemaker:AddAssociation",
      "sagemaker:AddTags",
      "sagemaker:AssociateTrialComponent",
      "sagemaker:BatchDescribeModelPackage",
      "sagemaker:BatchGetMetrics",
      "sagemaker:BatchGetRecord",
      "sagemaker:BatchPutMetrics",
      "sagemaker:CreateAction",
      "sagemaker:CreateAlgorithm",
      "sagemaker:CreateApp",
      "sagemaker:CreateAppImageConfig",
      "sagemaker:CreateArtifact",
      "sagemaker:CreateAutoMLJob",
      "sagemaker:CreateCodeRepository",
      "sagemaker:CreateCompilationJob",
      "sagemaker:CreateContext",
      "sagemaker:CreateDataQualityJobDefinition",
      "sagemaker:CreateDeviceFleet",
      "sagemaker:CreateDomain",
      "sagemaker:CreateEdgePackagingJob",
      "sagemaker:CreateEndpoint",
      "sagemaker:CreateEndpointConfig",
      "sagemaker:CreateExperiment",
      "sagemaker:CreateFeatureGroup",
      "sagemaker:CreateFlowDefinition",
      "sagemaker:CreateHumanTaskUi",
      "sagemaker:CreateHyperParameterTuningJob",
      "sagemaker:CreateImage",
      "sagemaker:CreateImageVersion",
      "sagemaker:CreateInferenceRecommendationsJob",
      "sagemaker:CreateLabelingJob",
      "sagemaker:CreateLineageGroupPolicy",
      "sagemaker:CreateModel",
      "sagemaker:CreateModelBiasJobDefinition",
      "sagemaker:CreateModelExplainabilityJobDefinition",
      "sagemaker:CreateModelPackage",
      "sagemaker:CreateModelPackageGroup",
      "sagemaker:CreateModelQualityJobDefinition",
      "sagemaker:CreateMonitoringSchedule",
      "sagemaker:CreateNotebookInstance",
      "sagemaker:CreateNotebookInstanceLifecycleConfig",
      "sagemaker:CreatePipeline",
      "sagemaker:CreatePresignedDomainUrl",
      "sagemaker:CreatePresignedNotebookInstanceUrl",
      "sagemaker:CreateProcessingJob",
      "sagemaker:CreateProject",
      "sagemaker:CreateTrainingJob",
      "sagemaker:CreateTransformJob",
      "sagemaker:CreateTrial",
      "sagemaker:CreateTrialComponent",
      "sagemaker:CreateUserProfile",
      "sagemaker:CreateWorkforce",
      "sagemaker:CreateWorkteam",
      "sagemaker:DeleteAction",
      "sagemaker:DeleteAlgorithm",
      "sagemaker:DeleteApp",
      "sagemaker:DeleteAppImageConfig",
      "sagemaker:DeleteArtifact",
      "sagemaker:DeleteAssociation",
      "sagemaker:DeleteCodeRepository",
      "sagemaker:DeleteContext",
      "sagemaker:DeleteDataQualityJobDefinition",
      "sagemaker:DeleteDeviceFleet",
      "sagemaker:DeleteDomain",
      "sagemaker:DeleteEndpoint",
      "sagemaker:DeleteEndpointConfig",
      "sagemaker:DeleteExperiment",
      "sagemaker:DeleteFeatureGroup",
      "sagemaker:DeleteFlowDefinition",
      "sagemaker:DeleteHumanLoop",
      "sagemaker:DeleteHumanTaskUi",
      "sagemaker:DeleteImage",
      "sagemaker:DeleteImageVersion",
      "sagemaker:DeleteLineageGroupPolicy",
      "sagemaker:DeleteModel",
      "sagemaker:DeleteModelBiasJobDefinition",
      "sagemaker:DeleteModelExplainabilityJobDefinition",
      "sagemaker:DeleteModelPackage",
      "sagemaker:DeleteModelPackageGroup",
      "sagemaker:DeleteModelPackageGroupPolicy",
      "sagemaker:DeleteModelQualityJobDefinition",
      "sagemaker:DeleteMonitoringSchedule",
      "sagemaker:DeleteNotebookInstance",
      "sagemaker:DeleteNotebookInstanceLifecycleConfig",
      "sagemaker:DeletePipeline",
      "sagemaker:DeleteProject",
      "sagemaker:DeleteRecord",
      "sagemaker:DeleteTags",
      "sagemaker:DeleteTrial",
      "sagemaker:DeleteTrialComponent",
      "sagemaker:DeleteUserProfile",
      "sagemaker:DeleteWorkforce",
      "sagemaker:DeleteWorkteam",
      "sagemaker:DeregisterDevices",
      "sagemaker:DescribeAction",
      "sagemaker:DescribeAlgorithm",
      "sagemaker:DescribeApp",
      "sagemaker:DescribeAppImageConfig",
      "sagemaker:DescribeArtifact",
      "sagemaker:DescribeAutoMLJob",
      "sagemaker:DescribeCodeRepository",
      "sagemaker:DescribeCompilationJob",
      "sagemaker:DescribeContext",
      "sagemaker:DescribeDataQualityJobDefinition",
      "sagemaker:DescribeDevice",
      "sagemaker:DescribeDeviceFleet",
      "sagemaker:DescribeDomain",
      "sagemaker:DescribeEdgePackagingJob",
      "sagemaker:DescribeEndpoint",
      "sagemaker:DescribeEndpointConfig",
      "sagemaker:DescribeExperiment",
      "sagemaker:DescribeFeatureGroup",
      "sagemaker:DescribeFlowDefinition",
      "sagemaker:DescribeHumanLoop",
      "sagemaker:DescribeHumanTaskUi",
      "sagemaker:DescribeHyperParameterTuningJob",
      "sagemaker:DescribeImage",
      "sagemaker:DescribeImageVersion",
      "sagemaker:DescribeInferenceRecommendationsJob",
      "sagemaker:DescribeLabelingJob",
      "sagemaker:DescribeLineageGroup",
      "sagemaker:DescribeModel",
      "sagemaker:DescribeModelBiasJobDefinition",
      "sagemaker:DescribeModelExplainabilityJobDefinition",
      "sagemaker:DescribeModelPackage",
      "sagemaker:DescribeModelPackageGroup",
      "sagemaker:DescribeModelQualityJobDefinition",
      "sagemaker:DescribeMonitoringSchedule",
      "sagemaker:DescribeNotebookInstance",
      "sagemaker:DescribeNotebookInstanceLifecycleConfig",
      "sagemaker:DescribePipeline",
      "sagemaker:DescribePipelineDefinitionForExecution",
      "sagemaker:DescribePipelineExecution",
      "sagemaker:DescribeProcessingJob",
      "sagemaker:DescribeProject",
      "sagemaker:DescribeSubscribedWorkteam",
      "sagemaker:DescribeTrainingJob",
      "sagemaker:DescribeTransformJob",
      "sagemaker:DescribeTrial",
      "sagemaker:DescribeTrialComponent",
      "sagemaker:DescribeUserProfile",
      "sagemaker:DescribeWorkforce",
      "sagemaker:DescribeWorkteam",
      "sagemaker:DisableSagemakerServicecatalogPortfolio",
      "sagemaker:DisassociateTrialComponent",
      "sagemaker:EnableSagemakerServicecatalogPortfolio",
      "sagemaker:GetDeviceFleetReport",
      "sagemaker:GetDeviceRegistration",
      "sagemaker:GetLineageGroupPolicy",
      "sagemaker:GetModelPackageGroupPolicy",
      "sagemaker:GetRecord",
      "sagemaker:GetSagemakerServicecatalogPortfolioStatus",
      "sagemaker:GetSearchSuggestions",
      "sagemaker:InvokeEndpoint",
      "sagemaker:InvokeEndpointAsync",
      "sagemaker:ListActions",
      "sagemaker:ListAlgorithms",
      "sagemaker:ListAppImageConfigs",
      "sagemaker:ListApps",
      "sagemaker:ListArtifacts",
      "sagemaker:ListAssociations",
      "sagemaker:ListAutoMLJobs",
      "sagemaker:ListCandidatesForAutoMLJob",
      "sagemaker:ListCodeRepositories",
      "sagemaker:ListCompilationJobs",
      "sagemaker:ListContexts",
      "sagemaker:ListDataQualityJobDefinitions",
      "sagemaker:ListDeviceFleets",
      "sagemaker:ListDevices",
      "sagemaker:ListDomains",
      "sagemaker:ListEdgePackagingJobs",
      "sagemaker:ListEndpointConfigs",
      "sagemaker:ListEndpoints",
      "sagemaker:ListExperiments",
      "sagemaker:ListFeatureGroups",
      "sagemaker:ListFlowDefinitions",
      "sagemaker:ListHumanLoops",
      "sagemaker:ListHumanTaskUis",
      "sagemaker:ListHyperParameterTuningJobs",
      "sagemaker:ListImageVersions",
      "sagemaker:ListImages",
      "sagemaker:ListInferenceRecommendationsJobs",
      "sagemaker:ListLabelingJobs",
      "sagemaker:ListLabelingJobsForWorkteam",
      "sagemaker:ListLineageGroups",
      "sagemaker:ListModelBiasJobDefinitions",
      "sagemaker:ListModelExplainabilityJobDefinitions",
      "sagemaker:ListModelMetadata",
      "sagemaker:ListModelPackageGroups",
      "sagemaker:ListModelPackages",
      "sagemaker:ListModelQualityJobDefinitions",
      "sagemaker:ListModels",
      "sagemaker:ListMonitoringExecutions",
      "sagemaker:ListMonitoringSchedules",
      "sagemaker:ListNotebookInstanceLifecycleConfigs",
      "sagemaker:ListNotebookInstances",
      "sagemaker:ListPipelineExecutionSteps",
      "sagemaker:ListPipelineExecutions",
      "sagemaker:ListPipelineParametersForExecution",
      "sagemaker:ListPipelines",
      "sagemaker:ListProcessingJobs",
      "sagemaker:ListProjects",
      "sagemaker:ListSubscribedWorkteams",
      "sagemaker:ListTags",
      "sagemaker:ListTrainingJobs",
      "sagemaker:ListTrainingJobsForHyperParameterTuningJob",
      "sagemaker:ListTransformJobs",
      "sagemaker:ListTrialComponents",
      "sagemaker:ListTrials",
      "sagemaker:ListUserProfiles",
      "sagemaker:ListWorkforces",
      "sagemaker:ListWorkteams",
      "sagemaker:PutLineageGroupPolicy",
      "sagemaker:PutModelPackageGroupPolicy",
      "sagemaker:PutRecord",
      "sagemaker:QueryLineage",
      "sagemaker:RegisterDevices",
      "sagemaker:RenderUiTemplate",
      "sagemaker:Search",
      "sagemaker:SendHeartbeat",
      "sagemaker:SendPipelineExecutionStepFailure",
      "sagemaker:SendPipelineExecutionStepSuccess",
      "sagemaker:StartHumanLoop",
      "sagemaker:StartMonitoringSchedule",
      "sagemaker:StartNotebookInstance",
      "sagemaker:StartPipelineExecution",
      "sagemaker:StopAutoMLJob",
      "sagemaker:StopCompilationJob",
      "sagemaker:StopEdgePackagingJob",
      "sagemaker:StopHumanLoop",
      "sagemaker:StopHyperParameterTuningJob",
      "sagemaker:StopInferenceRecommendationsJob",
      "sagemaker:StopLabelingJob",
      "sagemaker:StopMonitoringSchedule",
      "sagemaker:StopNotebookInstance",
      "sagemaker:StopPipelineExecution",
      "sagemaker:StopProcessingJob",
      "sagemaker:StopTrainingJob",
      "sagemaker:StopTransformJob",
      "sagemaker:UpdateAction",
      "sagemaker:UpdateAppImageConfig",
      "sagemaker:UpdateArtifact",
      "sagemaker:UpdateCodeRepository",
      "sagemaker:UpdateContext",
      "sagemaker:UpdateDeviceFleet",
      "sagemaker:UpdateDevices",
      "sagemaker:UpdateDomain",
      "sagemaker:UpdateEndpoint",
      "sagemaker:UpdateEndpointWeightsAndCapacities",
      "sagemaker:UpdateExperiment",
      "sagemaker:UpdateImage",
      "sagemaker:UpdateModelPackage",
      "sagemaker:UpdateMonitoringSchedule",
      "sagemaker:UpdateNotebookInstance",
      "sagemaker:UpdateNotebookInstanceLifecycleConfig",
      "sagemaker:UpdatePipeline",
      "sagemaker:UpdatePipelineExecution",
      "sagemaker:UpdateProject",
      "sagemaker:UpdateTrainingJob",
      "sagemaker:UpdateTrial",
      "sagemaker:UpdateTrialComponent",
      "sagemaker:UpdateUserProfile",
      "sagemaker:UpdateWorkforce",
      "sagemaker:UpdateWorkteam",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:iam::*:role/service-role/AmazonSageMakerServiceCatalogProductsCodeBuildRole",
      "arn:aws:iam::*:role/service-role/AmazonSageMakerServiceCatalogProductsExecutionRole",
    ]

    actions = ["iam:PassRole"]
  }
}

data "aws_iam_policy_document" "service_catalog_products_cloudformation_assume_role_policy" {
  statement {
    actions             = ["sts:AssumeRole"]

    principals {
      type              = "Service"
      identifiers       = ["cloudformation.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsCloudformationRole" {
  name                  = "AmazonSageMakerServiceCatalogProductsCloudformationRole"
  path                  = "/service-role/"
  assume_role_policy    = data.aws_iam_policy_document.service_catalog_products_cloudformation_assume_role_policy.json

  inline_policy {
    name                = "service_catalog_products_service_role_policy"
    policy              = data.aws_iam_policy_document.service_catalog_products_cloudformation_role_policy.json
  }
}

## -------- SageMaker -> Service Catalog -> CloudFormation -> Code Build

# Adapted from AWS managed policy: AmazonSageMakerServiceCatalogProductsCodeBuildServiceRolePolicy 
# This policy is intended to be used by the AmazonSageMakerServiceCatalogProductsCodeBuildRole role 
# created from the SageMaker console. The policy adds permissions to provision AWS resources for 
# SageMaker projects and JumpStart using Service Catalog to a customer's account.
data "aws_iam_policy_document" "service_catalog_products_codebuild_role_policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:codecommit:*:*:sagemaker-*"]

    actions = [
      "codecommit:CancelUploadArchive",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImageScanFindings",
      "ecr:DescribeRegistry",
      "ecr:DescribeImageReplicationStatus",
      "ecr:DescribeRepositories",
      "ecr:DescribeImageReplicationStatus",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:ecr:*:*:repository/sagemaker-*"]

    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:CreateRepository",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:iam::*:role/service-role/AmazonSageMakerServiceCatalogProductsEventsRole",
      "arn:aws:iam::*:role/service-role/AmazonSageMakerServiceCatalogProductsCodePipelineRole",
      "arn:aws:iam::*:role/service-role/AmazonSageMakerServiceCatalogProductsCloudformationRole",
      "arn:aws:iam::*:role/service-role/AmazonSageMakerServiceCatalogProductsCodeBuildRole",
      "arn:aws:iam::*:role/service-role/AmazonSageMakerServiceCatalogProductsExecutionRole",
    ]

    actions = ["iam:PassRole"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"

      values = [
        "events.amazonaws.com",
        "codepipeline.amazonaws.com",
        "cloudformation.amazonaws.com",
        "codebuild.amazonaws.com",
        "sagemaker.amazonaws.com",
      ]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:log-group:/aws/codebuild/*"]

    actions = [
      "logs:CreateLogDelivery",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogDelivery",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DescribeResourcePolicies",
      "logs:DescribeDestinations",
      "logs:DescribeExportTasks",
      "logs:DescribeMetricFilters",
      "logs:DescribeQueries",
      "logs:DescribeQueryDefinitions",
      "logs:DescribeSubscriptionFilters",
      "logs:GetLogDelivery",
      "logs:GetLogEvents",
      "logs:ListLogDeliveries",
      "logs:PutLogEvents",
      "logs:PutResourcePolicy",
      "logs:UpdateLogDelivery",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:s3:::aws-glue-*",
      "arn:aws:s3:::sagemaker-*",
    ]

    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:GetBucketAcl",
      "s3:GetBucketCors",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutBucketCors",
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:sagemaker:*:*:endpoint/*",
      "arn:aws:sagemaker:*:*:endpoint-config/*",
      "arn:aws:sagemaker:*:*:model/*",
      "arn:aws:sagemaker:*:*:pipeline/*",
      "arn:aws:sagemaker:*:*:project/*",
      "arn:aws:sagemaker:*:*:model-package/*",
    ]

    actions = [
      "sagemaker:*", 
      /*
      # individually listing each action makes this inline policy exceed 10k limit
      "sagemaker:AddAssociation",
      "sagemaker:AddTags",
      "sagemaker:AssociateTrialComponent",
      "sagemaker:BatchDescribeModelPackage",
      "sagemaker:BatchGetMetrics",
      "sagemaker:BatchGetRecord",
      "sagemaker:BatchPutMetrics",
      "sagemaker:CreateAction",
      "sagemaker:CreateAlgorithm",
      "sagemaker:CreateApp",
      "sagemaker:CreateAppImageConfig",
      "sagemaker:CreateArtifact",
      "sagemaker:CreateAutoMLJob",
      "sagemaker:CreateCodeRepository",
      "sagemaker:CreateCompilationJob",
      "sagemaker:CreateContext",
      "sagemaker:CreateDataQualityJobDefinition",
      "sagemaker:CreateDeviceFleet",
      "sagemaker:CreateDomain",
      "sagemaker:CreateEdgePackagingJob",
      "sagemaker:CreateEndpoint",
      "sagemaker:CreateEndpointConfig",
      "sagemaker:CreateExperiment",
      "sagemaker:CreateFeatureGroup",
      "sagemaker:CreateFlowDefinition",
      "sagemaker:CreateHumanTaskUi",
      "sagemaker:CreateHyperParameterTuningJob",
      "sagemaker:CreateImage",
      "sagemaker:CreateImageVersion",
      "sagemaker:CreateInferenceRecommendationsJob",
      "sagemaker:CreateLabelingJob",
      "sagemaker:CreateLineageGroupPolicy",
      "sagemaker:CreateModel",
      "sagemaker:CreateModelBiasJobDefinition",
      "sagemaker:CreateModelExplainabilityJobDefinition",
      "sagemaker:CreateModelPackage",
      "sagemaker:CreateModelPackageGroup",
      "sagemaker:CreateModelQualityJobDefinition",
      "sagemaker:CreateMonitoringSchedule",
      "sagemaker:CreateNotebookInstance",
      "sagemaker:CreateNotebookInstanceLifecycleConfig",
      "sagemaker:CreatePipeline",
      "sagemaker:CreatePresignedDomainUrl",
      "sagemaker:CreatePresignedNotebookInstanceUrl",
      "sagemaker:CreateProcessingJob",
      "sagemaker:CreateProject",
      "sagemaker:CreateTrainingJob",
      "sagemaker:CreateTransformJob",
      "sagemaker:CreateTrial",
      "sagemaker:CreateTrialComponent",
      "sagemaker:CreateUserProfile",
      "sagemaker:CreateWorkforce",
      "sagemaker:CreateWorkteam",
      "sagemaker:DeleteAction",
      "sagemaker:DeleteAlgorithm",
      "sagemaker:DeleteApp",
      "sagemaker:DeleteAppImageConfig",
      "sagemaker:DeleteArtifact",
      "sagemaker:DeleteAssociation",
      "sagemaker:DeleteCodeRepository",
      "sagemaker:DeleteContext",
      "sagemaker:DeleteDataQualityJobDefinition",
      "sagemaker:DeleteDeviceFleet",
      "sagemaker:DeleteDomain",
      "sagemaker:DeleteEndpoint",
      "sagemaker:DeleteEndpointConfig",
      "sagemaker:DeleteExperiment",
      "sagemaker:DeleteFeatureGroup",
      "sagemaker:DeleteFlowDefinition",
      "sagemaker:DeleteHumanLoop",
      "sagemaker:DeleteHumanTaskUi",
      "sagemaker:DeleteImage",
      "sagemaker:DeleteImageVersion",
      "sagemaker:DeleteLineageGroupPolicy",
      "sagemaker:DeleteModel",
      "sagemaker:DeleteModelBiasJobDefinition",
      "sagemaker:DeleteModelExplainabilityJobDefinition",
      "sagemaker:DeleteModelPackage",
      "sagemaker:DeleteModelPackageGroup",
      "sagemaker:DeleteModelPackageGroupPolicy",
      "sagemaker:DeleteModelQualityJobDefinition",
      "sagemaker:DeleteMonitoringSchedule",
      "sagemaker:DeleteNotebookInstance",
      "sagemaker:DeleteNotebookInstanceLifecycleConfig",
      "sagemaker:DeletePipeline",
      "sagemaker:DeleteProject",
      "sagemaker:DeleteRecord",
      "sagemaker:DeleteTags",
      "sagemaker:DeleteTrial",
      "sagemaker:DeleteTrialComponent",
      "sagemaker:DeleteUserProfile",
      "sagemaker:DeleteWorkforce",
      "sagemaker:DeleteWorkteam",
      "sagemaker:DeregisterDevices",
      "sagemaker:DescribeAction",
      "sagemaker:DescribeAlgorithm",
      "sagemaker:DescribeApp",
      "sagemaker:DescribeAppImageConfig",
      "sagemaker:DescribeArtifact",
      "sagemaker:DescribeAutoMLJob",
      "sagemaker:DescribeCodeRepository",
      "sagemaker:DescribeCompilationJob",
      "sagemaker:DescribeContext",
      "sagemaker:DescribeDataQualityJobDefinition",
      "sagemaker:DescribeDevice",
      "sagemaker:DescribeDeviceFleet",
      "sagemaker:DescribeDomain",
      "sagemaker:DescribeEdgePackagingJob",
      "sagemaker:DescribeEndpoint",
      "sagemaker:DescribeEndpointConfig",
      "sagemaker:DescribeExperiment",
      "sagemaker:DescribeFeatureGroup",
      "sagemaker:DescribeFlowDefinition",
      "sagemaker:DescribeHumanLoop",
      "sagemaker:DescribeHumanTaskUi",
      "sagemaker:DescribeHyperParameterTuningJob",
      "sagemaker:DescribeImage",
      "sagemaker:DescribeImageVersion",
      "sagemaker:DescribeInferenceRecommendationsJob",
      "sagemaker:DescribeLabelingJob",
      "sagemaker:DescribeLineageGroup",
      "sagemaker:DescribeModel",
      "sagemaker:DescribeModelBiasJobDefinition",
      "sagemaker:DescribeModelExplainabilityJobDefinition",
      "sagemaker:DescribeModelPackage",
      "sagemaker:DescribeModelPackageGroup",
      "sagemaker:DescribeModelQualityJobDefinition",
      "sagemaker:DescribeMonitoringSchedule",
      "sagemaker:DescribeNotebookInstance",
      "sagemaker:DescribeNotebookInstanceLifecycleConfig",
      "sagemaker:DescribePipeline",
      "sagemaker:DescribePipelineDefinitionForExecution",
      "sagemaker:DescribePipelineExecution",
      "sagemaker:DescribeProcessingJob",
      "sagemaker:DescribeProject",
      "sagemaker:DescribeSubscribedWorkteam",
      "sagemaker:DescribeTrainingJob",
      "sagemaker:DescribeTransformJob",
      "sagemaker:DescribeTrial",
      "sagemaker:DescribeTrialComponent",
      "sagemaker:DescribeUserProfile",
      "sagemaker:DescribeWorkforce",
      "sagemaker:DescribeWorkteam",
      "sagemaker:DisableSagemakerServicecatalogPortfolio",
      "sagemaker:DisassociateTrialComponent",
      "sagemaker:EnableSagemakerServicecatalogPortfolio",
      "sagemaker:GetDeviceFleetReport",
      "sagemaker:GetDeviceRegistration",
      "sagemaker:GetLineageGroupPolicy",
      "sagemaker:GetModelPackageGroupPolicy",
      "sagemaker:GetRecord",
      "sagemaker:GetSagemakerServicecatalogPortfolioStatus",
      "sagemaker:GetSearchSuggestions",
      "sagemaker:InvokeEndpoint",
      "sagemaker:InvokeEndpointAsync",
      "sagemaker:ListActions",
      "sagemaker:ListAlgorithms",
      "sagemaker:ListAppImageConfigs",
      "sagemaker:ListApps",
      "sagemaker:ListArtifacts",
      "sagemaker:ListAssociations",
      "sagemaker:ListAutoMLJobs",
      "sagemaker:ListCandidatesForAutoMLJob",
      "sagemaker:ListCodeRepositories",
      "sagemaker:ListCompilationJobs",
      "sagemaker:ListContexts",
      "sagemaker:ListDataQualityJobDefinitions",
      "sagemaker:ListDeviceFleets",
      "sagemaker:ListDevices",
      "sagemaker:ListDomains",
      "sagemaker:ListEdgePackagingJobs",
      "sagemaker:ListEndpointConfigs",
      "sagemaker:ListEndpoints",
      "sagemaker:ListExperiments",
      "sagemaker:ListFeatureGroups",
      "sagemaker:ListFlowDefinitions",
      "sagemaker:ListHumanLoops",
      "sagemaker:ListHumanTaskUis",
      "sagemaker:ListHyperParameterTuningJobs",
      "sagemaker:ListImageVersions",
      "sagemaker:ListImages",
      "sagemaker:ListInferenceRecommendationsJobs",
      "sagemaker:ListLabelingJobs",
      "sagemaker:ListLabelingJobsForWorkteam",
      "sagemaker:ListLineageGroups",
      "sagemaker:ListModelBiasJobDefinitions",
      "sagemaker:ListModelExplainabilityJobDefinitions",
      "sagemaker:ListModelMetadata",
      "sagemaker:ListModelPackageGroups",
      "sagemaker:ListModelPackages",
      "sagemaker:ListModelQualityJobDefinitions",
      "sagemaker:ListModels",
      "sagemaker:ListMonitoringExecutions",
      "sagemaker:ListMonitoringSchedules",
      "sagemaker:ListNotebookInstanceLifecycleConfigs",
      "sagemaker:ListNotebookInstances",
      "sagemaker:ListPipelineExecutionSteps",
      "sagemaker:ListPipelineExecutions",
      "sagemaker:ListPipelineParametersForExecution",
      "sagemaker:ListPipelines",
      "sagemaker:ListProcessingJobs",
      "sagemaker:ListProjects",
      "sagemaker:ListSubscribedWorkteams",
      "sagemaker:ListTags",
      "sagemaker:ListTrainingJobs",
      "sagemaker:ListTrainingJobsForHyperParameterTuningJob",
      "sagemaker:ListTransformJobs",
      "sagemaker:ListTrialComponents",
      "sagemaker:ListTrials",
      "sagemaker:ListUserProfiles",
      "sagemaker:ListWorkforces",
      "sagemaker:ListWorkteams",
      "sagemaker:PutLineageGroupPolicy",
      "sagemaker:PutModelPackageGroupPolicy",
      "sagemaker:PutRecord",
      "sagemaker:QueryLineage",
      "sagemaker:RegisterDevices",
      "sagemaker:RenderUiTemplate",
      "sagemaker:Search",
      "sagemaker:SendHeartbeat",
      "sagemaker:SendPipelineExecutionStepFailure",
      "sagemaker:SendPipelineExecutionStepSuccess",
      "sagemaker:StartHumanLoop",
      "sagemaker:StartMonitoringSchedule",
      "sagemaker:StartNotebookInstance",
      "sagemaker:StartPipelineExecution",
      "sagemaker:StopAutoMLJob",
      "sagemaker:StopCompilationJob",
      "sagemaker:StopEdgePackagingJob",
      "sagemaker:StopHumanLoop",
      "sagemaker:StopHyperParameterTuningJob",
      "sagemaker:StopInferenceRecommendationsJob",
      "sagemaker:StopLabelingJob",
      "sagemaker:StopMonitoringSchedule",
      "sagemaker:StopNotebookInstance",
      "sagemaker:StopPipelineExecution",
      "sagemaker:StopProcessingJob",
      "sagemaker:StopTrainingJob",
      "sagemaker:StopTransformJob",
      "sagemaker:UpdateAction",
      "sagemaker:UpdateAppImageConfig",
      "sagemaker:UpdateArtifact",
      "sagemaker:UpdateCodeRepository",
      "sagemaker:UpdateContext",
      "sagemaker:UpdateDeviceFleet",
      "sagemaker:UpdateDevices",
      "sagemaker:UpdateDomain",
      "sagemaker:UpdateEndpoint",
      "sagemaker:UpdateEndpointWeightsAndCapacities",
      "sagemaker:UpdateExperiment",
      "sagemaker:UpdateImage",
      "sagemaker:UpdateModelPackage",
      "sagemaker:UpdateMonitoringSchedule",
      "sagemaker:UpdateNotebookInstance",
      "sagemaker:UpdateNotebookInstanceLifecycleConfig",
      "sagemaker:UpdatePipeline",
      "sagemaker:UpdatePipelineExecution",
      "sagemaker:UpdateProject",
      "sagemaker:UpdateTrainingJob",
      "sagemaker:UpdateTrial",
      "sagemaker:UpdateTrialComponent",
      "sagemaker:UpdateUserProfile",
      "sagemaker:UpdateWorkforce",
      "sagemaker:UpdateWorkteam",
      */
    ]
  }
}

data "aws_iam_policy_document" "service_catalog_products_codebuild_assume_role_policy" {
  statement {
    actions             = ["sts:AssumeRole"]

    principals {
      type              = "Service"
      identifiers       = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsCodeBuildRole" {
  name                  = "AmazonSageMakerServiceCatalogProductsCodeBuildRole"
  path                  = "/service-role/"
  assume_role_policy    = data.aws_iam_policy_document.service_catalog_products_codebuild_assume_role_policy.json

  inline_policy {
    name                = "service_catalog_products_service_role_policy"
    policy              = data.aws_iam_policy_document.service_catalog_products_codebuild_role_policy.json
  }
}

## -------- SageMaker -> Service Catalog -> CloudFormation -> Code Pipeline

# Adapted from AWS managed policy: AmazonSageMakerServiceCatalogProductsCodeBuildServiceRolePolicy 
# This policy is intended to be used by the AmazonSageMakerServiceCatalogProductsCodeBuildRole role 
# created from the SageMaker console. The policy adds permissions to provision AWS resources for 
# SageMaker projects and JumpStart using Service Catalog to a customer's account.
data "aws_iam_policy_document" "service_catalog_products_codepipeline_role_policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:cloudformation:*:*:stack/sagemaker-*"]

    actions = [
      "cloudformation:CreateChangeSet",
      "cloudformation:CreateStack",
      "cloudformation:DescribeChangeSet",
      "cloudformation:DeleteChangeSet",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStacks",
      "cloudformation:ExecuteChangeSet",
      "cloudformation:SetStackPolicy",
      "cloudformation:UpdateStack",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::sagemaker-*"]

    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:iam::*:role/service-role/AmazonSageMakerServiceCatalogProductsCloudformationRole"]
    actions   = ["iam:PassRole"]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:codebuild:*:*:project/sagemaker-*",
      "arn:aws:codebuild:*:*:build/sagemaker-*",
    ]

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:codecommit:*:*:sagemaker-*"]

    actions = [
      "codecommit:CancelUploadArchive",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive",
    ]
  }
}

data "aws_iam_policy_document" "service_catalog_products_codepipeline_assume_role_policy" {
  statement {
    actions             = ["sts:AssumeRole"]

    principals {
      type              = "Service"
      identifiers       = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsCodePipelineRole" {
  name                  = "AmazonSageMakerServiceCatalogProductsCodePipelineRole"
  path                  = "/service-role/"
  assume_role_policy    = data.aws_iam_policy_document.service_catalog_products_codepipeline_assume_role_policy.json

  inline_policy {
    name                = "service_catalog_products_service_role_policy"
    policy              = data.aws_iam_policy_document.service_catalog_products_codepipeline_role_policy.json
  }
}

## -------- SageMaker -> Service Catalog -> Events

# Adapted from AWS managed policy: AmazonSageMakerServiceCatalogProductsEventsServiceRolePolicy 
# This policy is intended to be used by the AmazonSageMakerServiceCatalogProductsEventsRole role 
# created from the SageMaker console. The policy adds permissions to provision AWS resources for 
# SageMaker projects and JumpStart using Service Catalog to a customer's account.
data "aws_iam_policy_document" "service_catalog_products_events_role_policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:codepipeline:*:*:sagemaker-*"]
    actions   = ["codepipeline:StartPipelineExecution"]
  }

}

data "aws_iam_policy_document" "service_catalog_products_events_assume_role_policy" {
  statement {
    actions             = ["sts:AssumeRole"]

    principals {
      type              = "Service"
      identifiers       = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsEventsRole" {
  name                  = "AmazonSageMakerServiceCatalogProductsEventsRole"
  path                  = "/service-role/"
  assume_role_policy    = data.aws_iam_policy_document.service_catalog_products_events_assume_role_policy.json

  inline_policy {
    name                = "service_catalog_products_service_role_policy"
    policy              = data.aws_iam_policy_document.service_catalog_products_events_role_policy.json
  }
}

## -------- SageMaker -> Service Catalog -> Firehose

# Adapted from AWS managed policy: AmazonSageMakerServiceCatalogProductsEventsServiceRolePolicy 
# This policy is intended to be used by the AmazonSageMakerServiceCatalogProductsFirehoseRole role 
# created from the SageMaker console. The policy adds permissions to provision AWS resources for 
# SageMaker projects and JumpStart using Service Catalog to a customer's account.
data "aws_iam_policy_document" "service_catalog_products_firehose_role_policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:firehose:*:*:deliverystream/sagemaker-*"]

    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
  }
}

data "aws_iam_policy_document" "service_catalog_products_firehose_assume_role_policy" {
  statement {
    actions             = ["sts:AssumeRole"]

    principals {
      type              = "Service"
      identifiers       = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsFirehoseRole" {
  name                  = "AmazonSageMakerServiceCatalogProductsFirehoseRole"
  path                  = "/service-role/"
  assume_role_policy    = data.aws_iam_policy_document.service_catalog_products_firehose_assume_role_policy.json

  inline_policy {
    name                = "service_catalog_products_service_role_policy"
    policy              = data.aws_iam_policy_document.service_catalog_products_firehose_role_policy.json
  }
}

## -------- SageMaker -> Service Catalog -> Glue

# Adapted from AWS managed policy: AmazonSageMakerServiceCatalogProductsGlueServiceRolePolicy 
# This policy is intended to be used by the AmazonSageMakerServiceCatalogProductsGlueRole role 
# created from the SageMaker console. The policy adds permissions to provision AWS resources for 
# SageMaker projects and JumpStart using Service Catalog to a customer's account.
data "aws_iam_policy_document" "service_catalog_products_glue_role_policy" {
  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:glue:*:*:catalog",
      "arn:aws:glue:*:*:database/default",
      "arn:aws:glue:*:*:database/global_temp",
      "arn:aws:glue:*:*:database/sagemaker-*",
      "arn:aws:glue:*:*:table/sagemaker-*",
      "arn:aws:glue:*:*:tableVersion/sagemaker-*",
    ]

    actions = [
      "glue:BatchCreatePartition",
      "glue:BatchDeletePartition",
      "glue:BatchDeleteTable",
      "glue:BatchDeleteTableVersion",
      "glue:BatchGetPartition",
      "glue:CreateDatabase",
      "glue:CreatePartition",
      "glue:CreateTable",
      "glue:DeletePartition",
      "glue:DeleteTable",
      "glue:DeleteTableVersion",
      "glue:GetDatabase",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetTableVersion",
      "glue:GetTableVersions",
      "glue:SearchTables",
      "glue:UpdatePartition",
      "glue:UpdateTable",
      "glue:GetUserDefinedFunctions",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:s3:::aws-glue-*",
      "arn:aws:s3:::sagemaker-*",
    ]

    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:GetBucketAcl",
      "s3:GetBucketCors",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutBucketCors",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:s3:::aws-glue-*",
      "arn:aws:s3:::sagemaker-*",
    ]

    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:log-group:/aws/glue/*"]

    actions = [
      "logs:CreateLogDelivery",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogDelivery",
      "logs:Describe*",
      "logs:GetLogDelivery",
      "logs:GetLogEvents",
      "logs:ListLogDeliveries",
      "logs:PutLogEvents",
      "logs:PutResourcePolicy",
      "logs:UpdateLogDelivery",
    ]
  }
}

data "aws_iam_policy_document" "service_catalog_products_glue_assume_role_policy" {
  statement {
    actions             = ["sts:AssumeRole"]

    principals {
      type              = "Service"
      identifiers       = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsGlueRole" {
  name                  = "AmazonSageMakerServiceCatalogProductsGlueRole"
  path                  = "/service-role/"
  assume_role_policy    = data.aws_iam_policy_document.service_catalog_products_glue_assume_role_policy.json

  inline_policy {
    name                = "service_catalog_products_service_role_policy"
    policy              = data.aws_iam_policy_document.service_catalog_products_glue_role_policy.json
  }
}

## -------- SageMaker -> Service Catalog -> Lambda

# Adapted from AWS managed policy: AmazonSageMakerServiceCatalogProductsLambdaServiceRolePolicy 
# This policy is intended to be used by the AmazonSageMakerServiceCatalogProductsLambdaRole role 
# created from the SageMaker console. The policy adds permissions to provision AWS resources for 
# SageMaker projects and JumpStart using Service Catalog to a customer's account.
data "aws_iam_policy_document" "service_catalog_products_lambda_role_policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:ecr:*:*:repository/sagemaker-*"]

    actions = [
      "ecr:DescribeImages",
      "ecr:BatchDeleteImage",
      "ecr:CompleteLayerUpload",
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:events:*:*:rule/sagemaker-*"]

    actions = [
      "events:DeleteRule",
      "events:DescribeRule",
      "events:PutRule",
      "events:PutTargets",
      "events:RemoveTargets",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:s3:::aws-glue-*",
      "arn:aws:s3:::sagemaker-*",
    ]

    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:GetBucketAcl",
      "s3:GetBucketCors",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutBucketCors",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:s3:::aws-glue-*",
      "arn:aws:s3:::sagemaker-*",
    ]

    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
    ]
  }

  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:sagemaker:*:*:action/*",
      "arn:aws:sagemaker:*:*:algorithm/*",
      "arn:aws:sagemaker:*:*:app-image-config/*",
      "arn:aws:sagemaker:*:*:artifact/*",
      "arn:aws:sagemaker:*:*:automl-job/*",
      "arn:aws:sagemaker:*:*:code-repository/*",
      "arn:aws:sagemaker:*:*:compilation-job/*",
      "arn:aws:sagemaker:*:*:context/*",
      "arn:aws:sagemaker:*:*:data-quality-job-definition/*",
      "arn:aws:sagemaker:*:*:device-fleet/*/device/*",
      "arn:aws:sagemaker:*:*:device-fleet/*",
      "arn:aws:sagemaker:*:*:edge-packaging-job/*",
      "arn:aws:sagemaker:*:*:endpoint/*",
      "arn:aws:sagemaker:*:*:endpoint-config/*",
      "arn:aws:sagemaker:*:*:experiment/*",
      "arn:aws:sagemaker:*:*:experiment-trial/*",
      "arn:aws:sagemaker:*:*:experiment-trial-component/*",
      "arn:aws:sagemaker:*:*:feature-group/*",
      "arn:aws:sagemaker:*:*:human-loop/*",
      "arn:aws:sagemaker:*:*:human-task-ui/*",
      "arn:aws:sagemaker:*:*:hyper-parameter-tuning-job/*",
      "arn:aws:sagemaker:*:*:image/*",
      "arn:aws:sagemaker:*:*:image-version/*/*",
      "arn:aws:sagemaker:*:*:inference-recommendations-job/*",
      "arn:aws:sagemaker:*:*:labeling-job/*",
      "arn:aws:sagemaker:*:*:model/*",
      "arn:aws:sagemaker:*:*:model-bias-job-definition/*",
      "arn:aws:sagemaker:*:*:model-explainability-job-definition/*",
      "arn:aws:sagemaker:*:*:model-package/*",
      "arn:aws:sagemaker:*:*:model-package-group/*",
      "arn:aws:sagemaker:*:*:model-quality-job-definition/*",
      "arn:aws:sagemaker:*:*:monitoring-schedule/*",
      "arn:aws:sagemaker:*:*:notebook-instance/*",
      "arn:aws:sagemaker:*:*:notebook-instance-lifecycle-config/*",
      "arn:aws:sagemaker:*:*:pipeline/*",
      "arn:aws:sagemaker:*:*:pipeline/*/execution/*",
      "arn:aws:sagemaker:*:*:processing-job/*",
      "arn:aws:sagemaker:*:*:project/*",
      "arn:aws:sagemaker:*:*:training-job/*",
      "arn:aws:sagemaker:*:*:transform-job/*",
      "arn:aws:sagemaker:*:*:workforce/*",
      "arn:aws:sagemaker:*:*:workteam/*",
    ]

    actions = [
      "sagemaker:*", 
      /*
      # individually listing each action makes this inline policy exceed 10k limit
      "sagemaker:AddAssociation",
      "sagemaker:AddTags",
      "sagemaker:AssociateTrialComponent",
      "sagemaker:BatchDescribeModelPackage",
      "sagemaker:BatchGetMetrics",
      "sagemaker:BatchGetRecord",
      "sagemaker:BatchPutMetrics",
      "sagemaker:CreateAction",
      "sagemaker:CreateAlgorithm",
      "sagemaker:CreateApp",
      "sagemaker:CreateAppImageConfig",
      "sagemaker:CreateArtifact",
      "sagemaker:CreateAutoMLJob",
      "sagemaker:CreateCodeRepository",
      "sagemaker:CreateCompilationJob",
      "sagemaker:CreateContext",
      "sagemaker:CreateDataQualityJobDefinition",
      "sagemaker:CreateDeviceFleet",
      "sagemaker:CreateDomain",
      "sagemaker:CreateEdgePackagingJob",
      "sagemaker:CreateEndpoint",
      "sagemaker:CreateEndpointConfig",
      "sagemaker:CreateExperiment",
      "sagemaker:CreateFeatureGroup",
      "sagemaker:CreateFlowDefinition",
      "sagemaker:CreateHumanTaskUi",
      "sagemaker:CreateHyperParameterTuningJob",
      "sagemaker:CreateImage",
      "sagemaker:CreateImageVersion",
      "sagemaker:CreateInferenceRecommendationsJob",
      "sagemaker:CreateLabelingJob",
      "sagemaker:CreateLineageGroupPolicy",
      "sagemaker:CreateModel",
      "sagemaker:CreateModelBiasJobDefinition",
      "sagemaker:CreateModelExplainabilityJobDefinition",
      "sagemaker:CreateModelPackage",
      "sagemaker:CreateModelPackageGroup",
      "sagemaker:CreateModelQualityJobDefinition",
      "sagemaker:CreateMonitoringSchedule",
      "sagemaker:CreateNotebookInstance",
      "sagemaker:CreateNotebookInstanceLifecycleConfig",
      "sagemaker:CreatePipeline",
      "sagemaker:CreatePresignedDomainUrl",
      "sagemaker:CreatePresignedNotebookInstanceUrl",
      "sagemaker:CreateProcessingJob",
      "sagemaker:CreateProject",
      "sagemaker:CreateTrainingJob",
      "sagemaker:CreateTransformJob",
      "sagemaker:CreateTrial",
      "sagemaker:CreateTrialComponent",
      "sagemaker:CreateUserProfile",
      "sagemaker:CreateWorkforce",
      "sagemaker:CreateWorkteam",
      "sagemaker:DeleteAction",
      "sagemaker:DeleteAlgorithm",
      "sagemaker:DeleteApp",
      "sagemaker:DeleteAppImageConfig",
      "sagemaker:DeleteArtifact",
      "sagemaker:DeleteAssociation",
      "sagemaker:DeleteCodeRepository",
      "sagemaker:DeleteContext",
      "sagemaker:DeleteDataQualityJobDefinition",
      "sagemaker:DeleteDeviceFleet",
      "sagemaker:DeleteDomain",
      "sagemaker:DeleteEndpoint",
      "sagemaker:DeleteEndpointConfig",
      "sagemaker:DeleteExperiment",
      "sagemaker:DeleteFeatureGroup",
      "sagemaker:DeleteFlowDefinition",
      "sagemaker:DeleteHumanLoop",
      "sagemaker:DeleteHumanTaskUi",
      "sagemaker:DeleteImage",
      "sagemaker:DeleteImageVersion",
      "sagemaker:DeleteLineageGroupPolicy",
      "sagemaker:DeleteModel",
      "sagemaker:DeleteModelBiasJobDefinition",
      "sagemaker:DeleteModelExplainabilityJobDefinition",
      "sagemaker:DeleteModelPackage",
      "sagemaker:DeleteModelPackageGroup",
      "sagemaker:DeleteModelPackageGroupPolicy",
      "sagemaker:DeleteModelQualityJobDefinition",
      "sagemaker:DeleteMonitoringSchedule",
      "sagemaker:DeleteNotebookInstance",
      "sagemaker:DeleteNotebookInstanceLifecycleConfig",
      "sagemaker:DeletePipeline",
      "sagemaker:DeleteProject",
      "sagemaker:DeleteRecord",
      "sagemaker:DeleteTags",
      "sagemaker:DeleteTrial",
      "sagemaker:DeleteTrialComponent",
      "sagemaker:DeleteUserProfile",
      "sagemaker:DeleteWorkforce",
      "sagemaker:DeleteWorkteam",
      "sagemaker:DeregisterDevices",
      "sagemaker:DescribeAction",
      "sagemaker:DescribeAlgorithm",
      "sagemaker:DescribeApp",
      "sagemaker:DescribeAppImageConfig",
      "sagemaker:DescribeArtifact",
      "sagemaker:DescribeAutoMLJob",
      "sagemaker:DescribeCodeRepository",
      "sagemaker:DescribeCompilationJob",
      "sagemaker:DescribeContext",
      "sagemaker:DescribeDataQualityJobDefinition",
      "sagemaker:DescribeDevice",
      "sagemaker:DescribeDeviceFleet",
      "sagemaker:DescribeDomain",
      "sagemaker:DescribeEdgePackagingJob",
      "sagemaker:DescribeEndpoint",
      "sagemaker:DescribeEndpointConfig",
      "sagemaker:DescribeExperiment",
      "sagemaker:DescribeFeatureGroup",
      "sagemaker:DescribeFlowDefinition",
      "sagemaker:DescribeHumanLoop",
      "sagemaker:DescribeHumanTaskUi",
      "sagemaker:DescribeHyperParameterTuningJob",
      "sagemaker:DescribeImage",
      "sagemaker:DescribeImageVersion",
      "sagemaker:DescribeInferenceRecommendationsJob",
      "sagemaker:DescribeLabelingJob",
      "sagemaker:DescribeLineageGroup",
      "sagemaker:DescribeModel",
      "sagemaker:DescribeModelBiasJobDefinition",
      "sagemaker:DescribeModelExplainabilityJobDefinition",
      "sagemaker:DescribeModelPackage",
      "sagemaker:DescribeModelPackageGroup",
      "sagemaker:DescribeModelQualityJobDefinition",
      "sagemaker:DescribeMonitoringSchedule",
      "sagemaker:DescribeNotebookInstance",
      "sagemaker:DescribeNotebookInstanceLifecycleConfig",
      "sagemaker:DescribePipeline",
      "sagemaker:DescribePipelineDefinitionForExecution",
      "sagemaker:DescribePipelineExecution",
      "sagemaker:DescribeProcessingJob",
      "sagemaker:DescribeProject",
      "sagemaker:DescribeSubscribedWorkteam",
      "sagemaker:DescribeTrainingJob",
      "sagemaker:DescribeTransformJob",
      "sagemaker:DescribeTrial",
      "sagemaker:DescribeTrialComponent",
      "sagemaker:DescribeUserProfile",
      "sagemaker:DescribeWorkforce",
      "sagemaker:DescribeWorkteam",
      "sagemaker:DisableSagemakerServicecatalogPortfolio",
      "sagemaker:DisassociateTrialComponent",
      "sagemaker:EnableSagemakerServicecatalogPortfolio",
      "sagemaker:GetDeviceFleetReport",
      "sagemaker:GetDeviceRegistration",
      "sagemaker:GetLineageGroupPolicy",
      "sagemaker:GetModelPackageGroupPolicy",
      "sagemaker:GetRecord",
      "sagemaker:GetSagemakerServicecatalogPortfolioStatus",
      "sagemaker:GetSearchSuggestions",
      "sagemaker:InvokeEndpoint",
      "sagemaker:InvokeEndpointAsync",
      "sagemaker:ListActions",
      "sagemaker:ListAlgorithms",
      "sagemaker:ListAppImageConfigs",
      "sagemaker:ListApps",
      "sagemaker:ListArtifacts",
      "sagemaker:ListAssociations",
      "sagemaker:ListAutoMLJobs",
      "sagemaker:ListCandidatesForAutoMLJob",
      "sagemaker:ListCodeRepositories",
      "sagemaker:ListCompilationJobs",
      "sagemaker:ListContexts",
      "sagemaker:ListDataQualityJobDefinitions",
      "sagemaker:ListDeviceFleets",
      "sagemaker:ListDevices",
      "sagemaker:ListDomains",
      "sagemaker:ListEdgePackagingJobs",
      "sagemaker:ListEndpointConfigs",
      "sagemaker:ListEndpoints",
      "sagemaker:ListExperiments",
      "sagemaker:ListFeatureGroups",
      "sagemaker:ListFlowDefinitions",
      "sagemaker:ListHumanLoops",
      "sagemaker:ListHumanTaskUis",
      "sagemaker:ListHyperParameterTuningJobs",
      "sagemaker:ListImageVersions",
      "sagemaker:ListImages",
      "sagemaker:ListInferenceRecommendationsJobs",
      "sagemaker:ListLabelingJobs",
      "sagemaker:ListLabelingJobsForWorkteam",
      "sagemaker:ListLineageGroups",
      "sagemaker:ListModelBiasJobDefinitions",
      "sagemaker:ListModelExplainabilityJobDefinitions",
      "sagemaker:ListModelMetadata",
      "sagemaker:ListModelPackageGroups",
      "sagemaker:ListModelPackages",
      "sagemaker:ListModelQualityJobDefinitions",
      "sagemaker:ListModels",
      "sagemaker:ListMonitoringExecutions",
      "sagemaker:ListMonitoringSchedules",
      "sagemaker:ListNotebookInstanceLifecycleConfigs",
      "sagemaker:ListNotebookInstances",
      "sagemaker:ListPipelineExecutionSteps",
      "sagemaker:ListPipelineExecutions",
      "sagemaker:ListPipelineParametersForExecution",
      "sagemaker:ListPipelines",
      "sagemaker:ListProcessingJobs",
      "sagemaker:ListProjects",
      "sagemaker:ListSubscribedWorkteams",
      "sagemaker:ListTags",
      "sagemaker:ListTrainingJobs",
      "sagemaker:ListTrainingJobsForHyperParameterTuningJob",
      "sagemaker:ListTransformJobs",
      "sagemaker:ListTrialComponents",
      "sagemaker:ListTrials",
      "sagemaker:ListUserProfiles",
      "sagemaker:ListWorkforces",
      "sagemaker:ListWorkteams",
      "sagemaker:PutLineageGroupPolicy",
      "sagemaker:PutModelPackageGroupPolicy",
      "sagemaker:PutRecord",
      "sagemaker:QueryLineage",
      "sagemaker:RegisterDevices",
      "sagemaker:RenderUiTemplate",
      "sagemaker:Search",
      "sagemaker:SendHeartbeat",
      "sagemaker:SendPipelineExecutionStepFailure",
      "sagemaker:SendPipelineExecutionStepSuccess",
      "sagemaker:StartHumanLoop",
      "sagemaker:StartMonitoringSchedule",
      "sagemaker:StartNotebookInstance",
      "sagemaker:StartPipelineExecution",
      "sagemaker:StopAutoMLJob",
      "sagemaker:StopCompilationJob",
      "sagemaker:StopEdgePackagingJob",
      "sagemaker:StopHumanLoop",
      "sagemaker:StopHyperParameterTuningJob",
      "sagemaker:StopInferenceRecommendationsJob",
      "sagemaker:StopLabelingJob",
      "sagemaker:StopMonitoringSchedule",
      "sagemaker:StopNotebookInstance",
      "sagemaker:StopPipelineExecution",
      "sagemaker:StopProcessingJob",
      "sagemaker:StopTrainingJob",
      "sagemaker:StopTransformJob",
      "sagemaker:UpdateAction",
      "sagemaker:UpdateAppImageConfig",
      "sagemaker:UpdateArtifact",
      "sagemaker:UpdateCodeRepository",
      "sagemaker:UpdateContext",
      "sagemaker:UpdateDeviceFleet",
      "sagemaker:UpdateDevices",
      "sagemaker:UpdateDomain",
      "sagemaker:UpdateEndpoint",
      "sagemaker:UpdateEndpointWeightsAndCapacities",
      "sagemaker:UpdateExperiment",
      "sagemaker:UpdateImage",
      "sagemaker:UpdateModelPackage",
      "sagemaker:UpdateMonitoringSchedule",
      "sagemaker:UpdateNotebookInstance",
      "sagemaker:UpdateNotebookInstanceLifecycleConfig",
      "sagemaker:UpdatePipeline",
      "sagemaker:UpdatePipelineExecution",
      "sagemaker:UpdateProject",
      "sagemaker:UpdateTrainingJob",
      "sagemaker:UpdateTrial",
      "sagemaker:UpdateTrialComponent",
      "sagemaker:UpdateUserProfile",
      "sagemaker:UpdateWorkforce",
      "sagemaker:UpdateWorkteam",
      */
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:iam::*:role/service-role/AmazonSageMakerServiceCatalogProductsExecutionRole"]
    actions   = ["iam:PassRole"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*"]

    actions = [
      "logs:CreateLogDelivery",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogDelivery",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DescribeResourcePolicies",
      "logs:DescribeDestinations",
      "logs:DescribeExportTasks",
      "logs:DescribeMetricFilters",
      "logs:DescribeQueries",
      "logs:DescribeQueryDefinitions",
      "logs:DescribeSubscriptionFilters",
      "logs:GetLogDelivery",
      "logs:GetLogEvents",
      "logs:ListLogDeliveries",
      "logs:PutLogEvents",
      "logs:PutResourcePolicy",
      "logs:UpdateLogDelivery",
    ]
  }
}

data "aws_iam_policy_document" "service_catalog_products_lambda_assume_role_policy" {
  statement {
    actions             = ["sts:AssumeRole"]

    principals {
      type              = "Service"
      identifiers       = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsLambdaRole" {
  name                  = "AmazonSageMakerServiceCatalogProductsLambdaRole"
  path                  = "/service-role/"
  assume_role_policy    = data.aws_iam_policy_document.service_catalog_products_lambda_assume_role_policy.json

  inline_policy {
    name                = "service_catalog_products_service_role_policy"
    policy              = data.aws_iam_policy_document.service_catalog_products_lambda_role_policy.json
  }
}

## -------- SageMaker -> Service Catalog -> SageMaker

# This policy is intended to be used by the AmazonSageMakerServiceCatalogProductsExecutionRole role 
# created from the SageMaker console. The policy adds permissions to provision AWS resources for 
# SageMaker projects and JumpStart using Service Catalog to a customer's account.
data "aws_iam_policy" "service_catalog_products_sagemaker_managed_policy" {
  name = "AmazonSageMakerFullAccess"
}

data "aws_iam_policy_document" "service_catalog_products_sagemaker_assume_role_policy" {
  statement {
    actions             = ["sts:AssumeRole"]

    principals {
      type              = "Service"
      identifiers       = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "AmazonSageMakerServiceCatalogProductsExecutionRole" {
  name                  = "AmazonSageMakerServiceCatalogProductsExecutionRole"
  path                  = "/service-role/"
  assume_role_policy    = data.aws_iam_policy_document.service_catalog_products_sagemaker_assume_role_policy.json

  managed_policy_arns   = [data.aws_iam_policy.service_catalog_products_sagemaker_managed_policy.arn]
}

