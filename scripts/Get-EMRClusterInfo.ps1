#
# EMR Cluster Export Script
#
# Purpose: Exports comprehensive details about an Amazon EMR cluster to a text file
# This script retrieves cluster configuration, settings, and job steps for documentation
# and troubleshooting purposes. Useful for replicating cluster setups or analyzing
# ETL job execution history.
#
# Output includes:
#   - Cluster details (status, instance types, applications, etc.)
#   - Configuration settings (Spark, Hadoop, Hive configurations)
#   - Execution steps (submitted jobs and their status)
#
# Usage Examples:
#   .\export-emr.ps1 -ClusterId j-3GLJMEYCORP14
#   .\export-emr.ps1 -ClusterId j-3GLJMEYCORP14 -Region us-east-1
#   .\export-emr.ps1 -ClusterId j-3GLJMEYCORP14 -OutFile "custom-export.txt"
#
# Requirements: AWS CLI installed and configured with appropriate permissions
#

param(
  [Parameter(Mandatory=$true)]
  [string]$ClusterId,                     # e.g. j-3GLJMEYCORP14
  [string]$Region = "us-west-2",
  [string]$OutFile = "emr-cluster-export.txt"
)

# Start fresh
"===== CLUSTER DETAILS =====" | Set-Content -Encoding UTF8 $OutFile
aws emr describe-cluster --cluster-id $ClusterId --region $Region --output text `
  | Add-Content -Encoding UTF8 $OutFile

"" | Add-Content -Encoding UTF8 $OutFile
"===== CONFIGURATIONS =====" | Add-Content -Encoding UTF8 $OutFile
aws emr describe-cluster --cluster-id $ClusterId --query 'Cluster.Configurations' --region $Region --output json `
  | Add-Content -Encoding UTF8 $OutFile

"" | Add-Content -Encoding UTF8 $OutFile
"===== STEPS =====" | Add-Content -Encoding UTF8 $OutFile
aws emr list-steps --cluster-id $ClusterId --region $Region --output json `
  | Add-Content -Encoding UTF8 $OutFile

Write-Host "Wrote export to $OutFile"
