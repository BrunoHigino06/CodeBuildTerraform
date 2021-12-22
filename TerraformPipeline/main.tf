provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAW4XSTZLAAE5CFJWU"
  secret_key = "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"
}

module "iam" {
  source = ".\\IAM\\"
}

module "Infrastructure" {
  source = ".\\Infrastructure\\"
  service_role_var = module.iam.CodeBuildRoleOutput
  role_arn_var = module.iam.CodePipelineRoleOutput
  
  
  depends_on = [
    module.iam
  ]
}