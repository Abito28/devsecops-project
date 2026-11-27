resource "aws_ecr_repository" "devsecops-dev-ecr-repo" {
  #checkov:skip=CKV_AWS_136:KMS key adds cost
  name                 = "devsecops-dev-ecr-repo"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

}

resource "aws_ecr_lifecycle_policy" "devsecops-dev-ecr-lifecycle-policy" {
  repository = aws_ecr_repository.devsecops-dev-ecr-repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
