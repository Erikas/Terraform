provider "aws" {
   region = "us-east-2"
}

# resource "aws_s3_bucket" "terraform_state" {
#     bucket = "terraform-state-example-buckete"

#     lifecycle {
#       prevent_destroy = true
#     }
  
# }

# resource "aws_s3_bucket_versioning" "enabled" {
#   bucket = aws_s3_bucket.terraform_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
#   bucket = aws_s3_bucket.terraform_state.id


# rule {
#   apply_server_side_encryption_by_default {
#     sse_algorithm = "AES256"
#   }
# }
# }

# resource "aws_s3_bucket_public_access_block" "default" {
#   bucket = aws_s3_bucket.terraform_state.id
#   block_public_acls = true
#   block_public_policy = true
#   ignore_public_acls = true
#   restrict_public_buckets = true
# }

# resource "aws_dynamodb_table" "terraform_locks" {
#   name = "terraform-state-example-buckete-locks"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

terraform {
  backend "s3" {
    bucket = "terraform-state-example-buckete"
    key = "workplaces/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "terraform-state-example-buckete-locks"
    encrypt = true
  }
}


resource "aws_instance" "ec2_example" {
     ami = "ami-0fb653ca2d3203ac1"
     instance_type = terraform.workspace == "default" ?  "t2.medium" : "t2.micro"
}