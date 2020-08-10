terraform {
  required_version = ">= 0.12.6"

  backend "s3" {
    bucket         = "ohw-terraform-state-bucket"
    key            = "ohw-second-bucket-config.tfstate"
    region         = "us-west-2"
    encrypt        = true
  }
}

provider "aws" {
  version = "2.59.0"
  region  = var.region
  profile = var.profile
}

data "aws_caller_identity" "current" {}

# Second bucket
resource "aws_s3_bucket" "hackweek-second-bucket" {
  bucket = "${var.name_prefix}bucket-${var.region}"
  acl    = "private"

  tags = {
    Owner = split("/", data.aws_caller_identity.current.arn)[1]
    AutoTag_Creator = data.aws_caller_identity.current.arn
    Project = "${var.name_prefix}project"
  }
}

# bucket access policy
resource "aws_iam_policy" "hackweek-second-bucket-access-policy" {
    name        = "${var.name_prefix}second-data-bucket-access-policy"
    path        = "/"
    description = "Permissions for Terraform-controlled EKS cluster creation and management"
    policy      = data.aws_iam_policy_document.hackweek-second-bucket-access-permissions.json
}

# bucket access policy data
data "aws_iam_policy_document" "hackweek-second-bucket-access-permissions" {
  version = "2012-10-17"

  statement {
    sid       = "${split("-",var.name_prefix)[0]}DataBucketListAccess"

    effect    = "Allow"

    actions   = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.hackweek-second-bucket.arn
    ]
  }

  statement {
    sid       = "${split("-",var.name_prefix)[0]}DataBucketReadWriteAccess"

    effect    = "Allow"

    actions   = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.hackweek-second-bucket.arn}/*"
    ]
  }
}

# Attach policy to existing role defined in s3-data-bucket.tf
resource "aws_iam_role_policy_attachment" "second-bucket-permissions" {
  role        = "${var.name_prefix}bucket-access-serviceaccount"
  policy_arn  = aws_iam_policy.hackweek-second-bucket-access-policy.arn
}
