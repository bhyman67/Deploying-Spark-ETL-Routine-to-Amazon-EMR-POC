# Deploying PySpark ETL Routine to Amazon EMR POC

## What This ETL Does

This proof-of-concept demonstrates a simple Spark ETL job that processes 2016 stock market data:

- **Extract**: Reads CSV stock data from S3 (ticker, date, OHLC prices, volume)
- **Transform**: Filters for high-volume trading days (volume > 250,000 shares)
- **Load**: Writes filtered results to a new Parquet table for analytics

```sql
INSERT OVERWRITE TABLE high_volume_stocks
SELECT ticker, the_date, open, high, low, close, vol
FROM 2016_stock_data
WHERE vol > 250000
```

The job runs on Amazon EMR and stores results in S3, making them queryable via Amazon Athena.

## 🛠️ AWS Setup Prerequisites

Before running this POC, you'll need to set up the following AWS resources and configurations:

### **1. IAM Roles & Policies**

**EMR Service Role:**
```bash
# Create EMR service role (if not exists)
aws iam create-role --role-name EMR_DefaultRole --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "elasticmapreduce.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}'

# Attach EMR service policy
aws iam attach-role-policy --role-name EMR_DefaultRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole
```

**EMR EC2 Instance Profile:**
```bash
# Create EC2 role for EMR instances
aws iam create-role --role-name EMR_EC2_DefaultRole --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}'

# Attach EC2 instance profile policy
aws iam attach-role-policy --role-name EMR_EC2_DefaultRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role

# Create instance profile
aws iam create-instance-profile --instance-profile-name EMR_EC2_DefaultRole
aws iam add-role-to-instance-profile --instance-profile-name EMR_EC2_DefaultRole --role-name EMR_EC2_DefaultRole
```

### **2. S3 Buckets**

Create S3 buckets for code storage and logging:
```bash
# Code bucket (replace with your bucket name)
aws s3 mb s3://my-emr-etl-bucket-poc

# Logs bucket (replace with your account ID and region)
aws s3 mb s3://aws-logs-{ACCOUNT-ID}-{REGION}
```

### **3. VPC & Security Groups**

Ensure you have:
- **VPC subnet ID** where EMR will run
- **Security groups** for master and core nodes (EMR can create default ones)

### **4. GitHub Repository Secrets**

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):
- `AWS_ACCESS_KEY_ID` - Your AWS access key
- `AWS_SECRET_ACCESS_KEY` - Your AWS secret access key

### **5. Update Configuration Values**

Update the following values in the workflow files to match your AWS environment:
- **Account ID**: Replace `146121144646` with your AWS account ID
- **Subnet ID**: Replace `subnet-06ea10d2d2e7afb5f` with your subnet
- **Security Group IDs**: Replace the `sg-*` values with your security groups
- **S3 Bucket Names**: Update bucket names to match your buckets
- **Region**: Confirm `us-west-2` or change to your preferred region

## Repo Structure & File Descriptions

### 📂 .github/workflows/

GitHub Actions CI/CD pipelines for automated deployment and ETL execution.

* **deploy.yml** → Automatic deployment triggered on pushes to `main`. Syncs ETL job code from `./jobs/` to S3 using secure OIDC authentication. Keeps your S3 bucket updated with latest code changes.

* **run-emr-etl.yml** → Manual workflow for complete ETL pipeline execution. Creates transient EMR cluster, uploads and runs the Spark job, waits for completion, then exports cluster logs and artifacts. Best for production-like ETL testing.

* **terraform-emr.yml** → Manual infrastructure deployment using Terraform. Creates persistent EMR cluster with your job pre-loaded. Useful for development environments where you want a long-running cluster.

### 📂 infra/

Terraform definitions for infrastructure.

* **main.tf** → Defines the EMR cluster, instance groups, roles, steps, log URIs, etc.
* **variables.tf** → Input variables for region, subnet, instance type, bucket names, roles, etc. Makes the infra reusable across environments.

### 📂 jobs/

Spark jobs (the actual ETL code you want to run).

* **poc_etl_job.py** → Python Spark script that performs Extract → Transform → Load. This is the business logic of your ETL pipeline.

### 📂 scripts/

Developer helper scripts (not production jobs).

* **Get-EMRClusterInfo.ps1** → PowerShell script to fetch/export cluster details, configs, and steps into a single text file. Useful for debugging, documentation, and learning.
 
 