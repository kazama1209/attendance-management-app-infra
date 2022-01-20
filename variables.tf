variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_account_id" {}
variable "domain_name" {}
variable "database_host" {}
variable "database_name" {}
variable "database_username" {}
variable "database_password" {}
variable "app_host" {}
variable "rails_master_key" {}
variable "rails_log_to_stdout" {}
variable "mailer_user_name" {}
variable "mailer_password" {}

# 作成するリソースのプレフィックス
variable "rsrc_prefix" {
  default = "myapp"
}
