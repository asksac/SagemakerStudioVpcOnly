# enables SageMaker 'Projects and Jumpstart' Service Catalog portfolio share
resource "aws_sagemaker_servicecatalog_portfolio_status" "main" {
  status                = "Enabled"
}

/*
This is a workaround, until terraform provides a data source to query 
service catalog portfolio shares. 
Source: https://github.com/hashicorp/terraform-provider-aws/issues/28348
*/
data "external" "portfolio_shares" {
  # depends_on is required because the
  # aws_sagemaker_servicecatalog_portfolio_status resource is responsible for
  # creating the portfolio share.
  depends_on            = [
    aws_sagemaker_servicecatalog_portfolio_status.main
  ]

  program               = [
    "aws", "servicecatalog", "list-accepted-portfolio-shares",
    "--output", "json",
    "--query", "PortfolioDetails[?ProviderName==`Amazon SageMaker`] | [0]"
  ]
}

resource "aws_servicecatalog_principal_portfolio_association" "main" {
  portfolio_id          = data.external.portfolio_shares.result.Id
  principal_arn         = aws_iam_role.ss_exec_role.arn
}

