#Main
module "send_logs_archive" {
  source              = "./modules/send-logs-archive"
  name_role_lambda    = "send_logs_to_archive-role"
  bucket_archive_name = "backups-logs-archive2"
}
