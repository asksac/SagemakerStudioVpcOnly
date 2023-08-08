# Setup a CodeArtifact repository to pull and cache Python packages from PyPi

# create a codeartifact domain
resource "aws_codeartifact_domain" "main" {
  domain                = lower("${var.app_shortcode}-${var.aws_env}-artifacts")
  encryption_key        = aws_kms_key.ca_domain_key.arn
}

# create our repository for PyPi

resource "aws_codeartifact_repository" "upstream" {
  repository            = "pypi-store"
  domain                = aws_codeartifact_domain.main.domain
}

resource "aws_codeartifact_repository" "pypi_repo" {
  repository            = "private_pypi"
  domain                = aws_codeartifact_domain.main.domain

  external_connections {
    external_connection_name = "public:pypi"
  }

  depends_on            = [ aws_codeartifact_repository.upstream ]
}


data "aws_iam_policy_document" "repo_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [
        aws_iam_role.ss_exec_role.arn
      ]
    }

    actions   = [
      "codeartifact:AssociateExternalConnection",
      "codeartifact:CopyPackageVersions",
      "codeartifact:DeletePackageVersions",
      "codeartifact:DescribePackageVersion",
      "codeartifact:DescribeRepository",
      "codeartifact:DisposePackageVersions",
      "codeartifact:GetPackageVersionReadme",
      "codeartifact:GetRepositoryEndpoint",
      "codeartifact:ListPackageVersionAssets",
      "codeartifact:ListPackageVersionDependencies",
      "codeartifact:ListPackageVersions",
      "codeartifact:ListPackages",
      "codeartifact:PublishPackageVersion",
      "codeartifact:PutPackageMetadata",
      "codeartifact:PutRepositoryPermissionsPolicy",
      "codeartifact:ReadFromRepository",
      "codeartifact:UpdatePackageVersionsStatus",
    ]
    resources = [ aws_codeartifact_repository.pypi_repo.arn ]
  }
}

resource "aws_codeartifact_repository_permissions_policy" "repo_permission" {
  repository            = aws_codeartifact_repository.pypi_repo.repository
  domain                = aws_codeartifact_domain.main.domain
  policy_document       = data.aws_iam_policy_document.repo_policy.json
}

