# PHI S3 Bucket Deployment

This repository contains Terraform configuration for deploying secure S3 buckets using the PHI-s3-bucket module v1.2.3.

## Overview

This configuration manages two S3 buckets:

1. **Existing Secure Data Bucket** (`my-secure-data-bucket`)
   - Updated to use module version v1.2.3
   - Configured with cross-region replication to us-west-2
   - Trusted principals include DataProcessingRole and data-scientist user

2. **New Secure Bucket with Object Lock** (`my-secure-bucket-with-object-lock`)
   - Uses a custom KMS key with rotation enabled
   - Object lock enabled with 30-day COMPLIANCE retention
   - Designed for immutable data storage

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Access to AWS account: 944737299127
- Permissions to create S3 buckets, KMS keys, and IAM policies

## File Structure

```
.
├── main.tf           # Main Terraform configuration
├── variables.tf      # Variable definitions
├── terraform.tfvars  # Variable values
└── README.md         # This file
```

## Usage

1. Initialize Terraform and download the module:
   ```bash
   terraform init -upgrade
   ```

2. Review the planned changes:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

## Configuration Details

### KMS Key
- Automatic key rotation enabled
- 10-day deletion window
- Alias: `alias/my-secure-bucket-key`

### Object Lock Configuration
- Mode: COMPLIANCE (cannot be bypassed)
- Retention: 30 days
- Applied by default to all objects

### Replication
- Primary region: us-east-1
- Replica region: us-west-2
- Only enabled for the existing data bucket

## IAM Principals

Make sure these IAM roles and users exist before applying:
- `arn:aws:iam::944737299127:role/DataProcessingRole`
- `arn:aws:iam::944737299127:user/data-scientist`
- `arn:aws:iam::944737299127:role/ApplicationRole`

## Outputs

The configuration provides the following outputs:
- `existing_bucket_id` - ID of the updated existing bucket
- `existing_bucket_arn` - ARN of the updated existing bucket
- `new_bucket_id` - ID of the new bucket with object lock
- `new_bucket_arn` - ARN of the new bucket with object lock
- `kms_key_id` - ID of the created KMS key
- `kms_key_arn` - ARN of the created KMS key

## Important Notes

- Object lock must be enabled during bucket creation and cannot be added later
- COMPLIANCE mode retention cannot be shortened or removed until the retention period expires
- Ensure proper backup procedures are in place before enabling object lock
- The KMS key deletion window is set to 10 days for safety

## Module Documentation

For more information about the PHI-s3-bucket module, visit:
https://github.com/phin3has/PHI-s3-bucket
