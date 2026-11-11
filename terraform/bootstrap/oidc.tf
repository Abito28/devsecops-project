locals {
  github_repo  = "Abito28/devsecops-project"
  state_bucket = "devsecops-dev-s3"
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  tags = {
    Name        = "devsecops-dev-oidc-provider"
    Project     = "devsecops"
    Owner       = "shimizu"
    Environment = "dev"
  }
}

resource "aws_iam_role" "plan" {
  name = "devsecops-dev-role-github-plan"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:${local.github_repo}:pull_request"
        }
      }
    }]
  })

  tags = {
    Name        = "devsecops-dev-role-plan"
    Project     = "devsecops"
    Owner       = "shimizu"
    Environment = "dev"
  }
}

resource "aws_iam_role_policy" "plan_state" {
  name = "terraform-state-access"
  role = aws_iam_role.plan.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::${local.state_bucket}"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "arn:aws:s3:::${local.state_bucket}/main/terraform.tfstate"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "arn:aws:s3:::${local.state_bucket}/main/terraform.tfstate.tflock"
      }
    ]
  })
}