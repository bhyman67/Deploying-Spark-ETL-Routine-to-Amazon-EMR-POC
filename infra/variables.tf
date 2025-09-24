variable "region" {
  description = "AWS region for EMR cluster and resources"
  type        = string
  default     = "us-west-2"
}

variable "emr_release" {
  description = "EMR release version (includes Spark, Hadoop versions)"
  type        = string
  default     = "emr-7.9.0"
}

variable "instance_type" {
  description = "EC2 instance type for all EMR nodes (master, core, task)"
  type        = string
  default     = "m5.xlarge"
}

variable "emr_service_role" {
  description = "IAM service role ARN for EMR cluster management"
  type        = string
}

variable "emr_ec2_role" {
  description = "IAM instance profile for EMR EC2 instances"
  type        = string
}

variable "subnet_id" {
  description = "VPC subnet ID where EMR cluster will be deployed"
  type        = string
}

variable "master_sg" {
  description = "Security group ID for EMR master node"
  type        = string
}

variable "core_sg" {
  description = "Security group ID for EMR core/task nodes"
  type        = string
}

variable "log_bucket" {
  description = "S3 bucket name for EMR cluster logs and debugging"
  type        = string
}

variable "code_bucket" {
  description = "S3 bucket name containing Spark job code"
  type        = string
}

variable "code_prefix" {
  description = "S3 prefix/folder path for Spark job files"
  type        = string
  default     = "jobs"
}

variable "configurations_json" {
  description = "JSON string for EMR application configurations (Spark, Hadoop, etc.)"
  type        = string
  default     = ""
}
