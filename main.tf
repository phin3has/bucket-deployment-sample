# main.tf - PHI S3 Bucket Configuration with Module v1.2.3

# Configure the AWS Provider
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Backend configuration for state management
  backend "s3" {
    bucket = "mvp-phi-storage-terraform-state"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
  }
}

# Primary provider configuration
provider "aws" {
  region = "us-east-1"
}

# Replica provider for replication
provider "aws" {
  alias  = "replica"
  region = "us-west-2"
}

# KMS key for the new bucket
resource "aws_kms_key" "my_bucket_key" {
  description             = "KMS key for my-secure-bucket"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "my-secure-bucket-key"
    Environment = "prod"
  }
}

resource "aws_kms_alias" "my_bucket_key_alias" {
  name          = "alias/my-secure-bucket-key"
  target_key_id = aws_kms_key.my_bucket_key.key_id
}

# Update existing bucket to use module version v1.2.3
module "existing_secure_bucket" {
  source  = "github.com/phin3has/PHI-s3-bucket?ref=v1.2.3"
  
  bucket_name = "my-secure-data-bucket"
  environment = "prod"
  
  # Specify trusted IAM principals
  trusted_principal_arns = [
    "arn:aws:iam::944737299127:role/DataProcessingRole",
    "arn:aws:iam::944737299127:user/data-scientist"
  ]
  
  # Enable replication to us-west-2
  enable_replication = true
  replication_region = "us-west-2"
  
  tags = {
    Project    = "DataLake"
    CostCenter = "Engineering"
  }
  
  providers = {
    aws         = aws
    aws.replica = aws.replica
  }
}

# New bucket with custom KMS key and object lock
module "new_secure_bucket_with_lock" {
  source  = "github.com/phin3has/PHI-s3-bucket?ref=v1.2.3"
  
  bucket_name = "my-secure-bucket-with-object-lock"
  environment = "prod"
  
  # Use the KMS key created above
  kms_key_arn = aws_kms_key.my_bucket_key.arn
  
  # Enable object lock
  enable_object_lock = true
  object_lock_configuration = {
    rule = {
      default_retention = {
        mode = "COMPLIANCE"
        days = 30
      }
    }
  }
  
  trusted_principal_arns = [
    "arn:aws:iam::944737299127:role/ApplicationRole"
  ]
  
  tags = {
    Project     = "SecureStorage"
    Environment = "prod"
    Feature     = "ObjectLock"
  }
  
  providers = {
    aws         = aws
    aws.replica = aws.replica
  }
}

# Outputs
output "existing_bucket_id" {
  description = "The ID of the existing updated bucket"
  value       = module.existing_secure_bucket.bucket_id
}

output "existing_bucket_arn" {
  description = "The ARN of the existing updated bucket"
  value       = module.existing_secure_bucket.bucket_arn
}

output "new_bucket_id" {
  description = "The ID of the new bucket with object lock"
  value       = module.new_secure_bucket_with_lock.bucket_id
}

output "new_bucket_arn" {
  description = "The ARN of the new bucket with object lock"
  value       = module.new_secure_bucket_with_lock.bucket_arn
}

output "kms_key_id" {
  description = "The ID of the KMS key created for the new bucket"
  value       = aws_kms_key.my_bucket_key.id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key created for the new bucket"
  value       = aws_kms_key.my_bucket_key.arn
}
