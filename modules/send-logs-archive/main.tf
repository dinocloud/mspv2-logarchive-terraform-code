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

  # Configurar la política del bucket
  policy = <<POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::767398058472:role/send_logs_to_archive-role"
                },
                "Action": [
                    "s3:PutObject",
                    "s3:*"
                ],
                "Resource": "arn:aws:s3:::backups-logs-archive2/*"
            }
        ]
    }
    POLICY
}

# Crear un rol de IAM con permisos para S3
resource "aws_iam_role" "send_logs_to_achive_role" {
  name = "send_logs_to_archive_role"

  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::767398058472:role/send_logs_to_archive-role"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
}

# Adjuntar políticas al rol de IAM
resource "aws_iam_policy" "s3_policy" {
  name        = "send_logs_to_achive_s3_policy"
  description = "Política para permitir acceso a S3"

  policy = <<POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:PutObject",
                    "s3:GetObject",
                    "s3:ListBucket",
                    "s3:DeleteObject"
                ],
                "Resource": [
                    "arn:aws:s3:::backups-logs-archive2",
                    "arn:aws:s3:::backups-logs-archive2/*"
                ]
            }
        ]
    }
    POLICY
}

# Vincular la política al rol
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.send_logs_to_achive_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}



# arn:aws:iam::767398058472:role/send_logs_to_archive-role
