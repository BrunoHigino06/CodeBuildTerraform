#Terraform Container ECR reporsitory

resource "aws_ecr_repository" "TerraformECR" {
  name = "terraform"
}

# Call the AWS Account ID 
data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
}

output "account_id" {
  value = local.account_id
}

# Starting terraform container for ECR

resource "null_resource" "TerraformTag" {
  provisioner "local-exec" {
    command = "docker tag ${var.DockerImage_var} ${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/terraform:latest"
  }
  depends_on = [
    aws_ecr_repository.TerraformECR,
    data.aws_caller_identity.current
  ]
}

resource "null_resource" "TerraformAuth" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.us-east-1.amazonaws.com"
  }
  depends_on = [
    aws_ecr_repository.TerraformECR,
    data.aws_caller_identity.current,
  ]
}


resource "null_resource" "TerraformPush" {
  provisioner "local-exec" {
    command = "docker push ${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/terraform:latest"
  }
  depends_on = [
    aws_ecr_repository.TerraformECR,
    data.aws_caller_identity.current,
    null_resource.TerraformTag,
    null_resource.TerraformAuth
  ]
}

# CloudBuild implantation

# Credentinal to acess the git private repository

resource "aws_codebuild_source_credential" "AcessToken" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = ""
}

# CloudBuild project

resource "aws_codebuild_project" "TerraformBuildProject" {
  name          = "TerraformBuildProject"
  description   = "TerraformBuildProject"
  build_timeout = "60"
  service_role  = var.service_role_var
  source_version = "main"
  source {
    type            = "GITHUB"
    location        = "https://github.com/BrunoHigino06/CodeBuildTerraform.git"
    git_clone_depth = 1
  }
  environment {
    compute_type = "BUILD_GENERAL1_LARGE"
    image = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/terraform:latest"
    type = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
  }
  artifacts {
    type = "NO_ARTIFACTS"
  }  
}

# CodePipeline implantation

#S3 for the artifact store

data "aws_canonical_user_id" "current_user" {}

resource "aws_s3_bucket" "CodePipelineBucket" {
  bucket = "codepipelinebucket20211222"
  acl = "private"
}

# Copy empty tfstate.tf to a S3 bucket
resource "null_resource" "TFStateCopy" {
  provisioner "local-exec" {
    command = "aws s3 cp .\\terraform.tfstate s3://${aws_s3_bucket.CodePipelineBucket.bucket}/TFState/terraform.tfstate"
  }
  depends_on = [
    aws_s3_bucket.CodePipelineBucket
  ]
}

resource "aws_codestarconnections_connection" "GitConnection" {
  name          = "GitConnection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "TerraformPipeline" {
  name     = "TerraformPipeline"
  role_arn = var.role_arn_var

  artifact_store {
    location = aws_s3_bucket.CodePipelineBucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.GitConnection.arn
        FullRepositoryId = "https://github.com/BrunoHigino06/CodeBuildTerraform.git"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.TerraformBuildProject.name
      }
    }
  }
  depends_on = [
    aws_s3_bucket.CodePipelineBucket,
    aws_codestarconnections_connection.GitConnection
  ]
}