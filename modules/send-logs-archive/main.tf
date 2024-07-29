terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
    }
  }
}

# Crear el bucket de S3
resource "aws_s3_bucket" "backups_logs_archive" {
  bucket = var.bucket_archive_name
}

# Cargar y procesar la política desde el archivo
data "template_file" "backups_policy_logs_archive" {
  template = file("${path.module}/policies/bucket-policy.json")
  vars = {
    name_role_lambda  = var.name_role_lambda
    bucket_archive_name = var.bucket_archive_name
  }
}

# Define the bucket policy
resource "aws_s3_bucket_policy" "backups_policy_logs_archive" {
  bucket = aws_s3_bucket.backups_logs_archive.bucket

  policy = data.template_file.backups_policy_logs_archive.rendered
}


# Cargar y procesar la política desde el archivo
data "template_file" "send_logs_to_archive_role" {
  template = file("${path.module}/policies/send-logs-role.json")
  vars = {
    name_role_lambda  = var.name_role_lambda
    bucket_archive_name = var.bucket_archive_name
  }
}

# Crear un rol de IAM con permisos para S3
resource "aws_iam_role" "send_logs_to_archive_role" {
  name = "role-to-receive-logs"

  assume_role_policy = data.template_file.send_logs_to_archive_role.rendered
}


# Cargar y procesar la política desde el archivo
data "template_file" "access_to_s3" {
  template = file("${path.module}/policies/access-to-s3.json")
  vars = {
    bucket_archive_name = var.bucket_archive_name
  }
}

# Adjuntar políticas al rol de IAM
resource "aws_iam_policy" "s3_policy" {
  name        = "send_logs_to_archive_s3_policy"
  description = "Política para permitir acceso a S3"

  policy = data.template_file.access_to_s3.rendered
}

# Vincular la política al rol
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.send_logs_to_archive_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}



