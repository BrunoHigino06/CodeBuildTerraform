provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAVP4CNBQWT5L7TBMG"
  secret_key = "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"
}

# Network

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "Default subnet for us-east-1a"
  }
}

resource "aws_security_group" "FrontEndSG" {
  name        = "FrontEndSG"
  description = "Allow frontend traffics"
  vpc_id      = aws_default_vpc.default.id

}

#Rule for the FrontEnd SG

#Ingress

resource "aws_security_group_rule" "FrontEndSGIngress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.FrontEndSG.id

  depends_on = [
    aws_security_group.FrontEndSG
  ]
}

resource "aws_security_group_rule" "FrontEndSGIngressSSH" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.FrontEndSG.id

  depends_on = [
    aws_security_group.FrontEndSG
  ]
}

#Egress

resource "aws_security_group_rule" "FrontEndSGEgress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.FrontEndSG.id

  depends_on = [
    aws_security_group.FrontEndSG
  ]
}

