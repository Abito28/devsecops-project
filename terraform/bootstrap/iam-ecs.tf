data "aws_caller_identity" "current" {}

locals {
  ecs_role_arn_pattern = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/devsecops-dev-role-ecs-*"
}

data "aws_iam_policy_document" "ecs_iam" {
  statement {
    sid    = "ManageEcsRoles"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:TagRole",
      "iam:UntagRole",
    ]
    resources = [local.ecs_role_arn_pattern]
  }

  statement {
    sid    = "AttachOnlyExecutionPolicy"
    effect = "Allow"
    actions = [
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
    ]
    resources = [local.ecs_role_arn_pattern]
    condition {
      test     = "ArnEquals"
      variable = "iam:PolicyARN"
      values   = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
    }
  }

  statement {
    sid       = "PassRoleToEcsOnly"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [local.ecs_role_arn_pattern]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }

  statement {
    sid    = "ReadEcsRoles"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListInstanceProfilesForRole",
    ]
    resources = [local.ecs_role_arn_pattern]
  }
}

resource "aws_iam_role_policy" "apply_ecs_iam" {
  name   = "devsecops-dev-policy-apply-ecs-iam"
  role   = aws_iam_role.apply.id
  policy = data.aws_iam_policy_document.ecs_iam.json
}

resource "aws_iam_role_policy" "destroy_ecs_iam" {
  name   = "devsecops-dev-policy-destroy-ecs-iam"
  role   = aws_iam_role.destroy.id
  policy = data.aws_iam_policy_document.ecs_iam.json
}