# Deploying-Spark-ETL-Routine-to-Amazon-EMR-POC

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
* **outputs.tf** → Exposes key info after `terraform apply` (cluster ID, master DNS, log URI, release label, ARN, apps installed) so pipelines/scripts can consume it.

### 📂 jobs/

Spark jobs (the actual ETL code you want to run).

* **poc_etl_job.py** → Python Spark script that performs Extract → Transform → Load. This is the business logic of your ETL pipeline.

### 📂 scripts/

Developer helper scripts (not production jobs).

* **Get-EMRClusterInfo.ps1** → PowerShell script to fetch/export cluster details, configs, and steps into a single text file. Useful for debugging, documentation, and learning.