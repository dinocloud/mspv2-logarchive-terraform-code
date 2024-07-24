#Main
module "send_logs_archive" {
    source = "./modules/send-logs-archive"
    bucket_operation_name = var.bucket_operation_name
    name_role_lambda = var.name_role_lambda
    account_id = var.account_id
    bucket_archive_name = var.bucket_archive_name
}