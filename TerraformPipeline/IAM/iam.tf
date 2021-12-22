# Role for code codebuild

resource "aws_iam_role" "CodeBuildRole" {
  name = "CodeBuildRole"
  assume_role_policy = "${file(".\\IAM\\CodeBuildAssumeRole.json")}"
  tags = {
    Name = "CodeBuildRole"
  }
}

output "CodeBuildRoleOutput" {
  value = aws_iam_role.CodeBuildRole.arn
}

resource "aws_iam_role_policy" "CodeBuildPolicy" {
  name = "CodeBuildPolicy"
  role = aws_iam_role.CodeBuildRole.id
  policy = "${file(".\\IAM\\CodeBuildPolicy.json")}"

  depends_on = [
    aws_iam_role.CodeBuildRole
  ]
}


# Role for EC2 Acess

resource "aws_iam_instance_profile" "EC2AcessProfile" {
  name = "EC2AcessProfile"
  role = aws_iam_role.EC2AcessRole.name
}

resource "aws_iam_role" "EC2AcessRole" {
  name = "EC2AcessRole"
  assume_role_policy = "${file(".\\IAM\\EC2AssumeRole.json")}"
  tags = {
    Name = "EC2AcessRole"
  }
}

# Policy that is attach to the EC2 Role

resource "aws_iam_role_policy" "EC2AcessPolicy" {
  name = "EC2AcessPolicy"
  role = aws_iam_role.EC2AcessRole.id

  policy = "${file(".\\IAM\\EC2AcessPolicy.json")}"

  depends_on = [
    aws_iam_role.EC2AcessRole
  ]
}

# Role for CodePipeline

resource "aws_iam_role" "CodePipelineRole" {
  name = "CodePipelineRole"
  assume_role_policy = "${file(".\\IAM\\CodePipelineAssumeRole.json")}"
  tags = {
    Name = "CodeBuildRole"
  }
}

resource "aws_iam_role_policy" "CodePipelinePolicy" {
  name = "CodePipelinePolicy"
  role = aws_iam_role.CodePipelineRole.id
  policy = "${file(".\\IAM\\CodePipelinePolicy.json")}"

  depends_on = [
    aws_iam_role.CodePipelineRole
  ]
}

output "CodePipelineRoleOutput" {
  value = aws_iam_role.CodePipelineRole.arn
}