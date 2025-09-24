terraform {
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
}
provider "aws" { region = var.region }

resource "aws_emr_cluster" "etl" {
  name          = "spark-etl-tf"
  release_label = var.emr_release
  applications  = ["Hadoop","Spark","Hive","Livy","JupyterEnterpriseGateway"]

  service_role = var.emr_service_role
  ec2_attributes {
    instance_profile = var.emr_ec2_role
    subnet_id        = var.subnet_id
    emr_managed_master_security_group = var.master_sg
    emr_managed_slave_security_group  = var.core_sg
  }

  log_uri      = "s3n://${var.log_bucket}/elasticmapreduce/"
  autoscaling_role = null

  master_instance_group {
    instance_type = var.instance_type
    instance_count = 1
  }
  core_instance_group {
    instance_type = var.instance_type
    instance_count = 1
  }
  task_instance_group {
    instance_type = var.instance_type
    instance_count = 1
  }

  step_concurrency_level = 1

  # Single spark step; cluster terminates after steps if you set:
  configurations_json = var.configurations_json
  visible_to_all_users = true
  keep_job_flow_alive_when_no_steps = false

  step {
    name = "poc-etl-job"
    action_on_failure = "TERMINATE_CLUSTER"
    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["spark-submit","--deploy-mode","cluster","s3://${var.code_bucket}/${var.code_prefix}/poc_etl_job.py"]
    }
  }

  tags = { Project = "emr-etl-poc", Owner = "Brent", Env = "dev" }
}
