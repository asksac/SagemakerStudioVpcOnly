data "aws_kms_key" "aws_s3_key" {
  key_id = "alias/aws/s3"
}

resource "aws_s3_bucket" "ss_bucket" {
  bucket_prefix             = "${var.ss_domain_name}-bucket"

  force_destroy             = false

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        #sse_algorithm       = "AES256" # "aws:kms"
        kms_master_key_id = data.aws_kms_key.aws_s3_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "ss_bucket_apply_policy" {
  bucket                    = aws_s3_bucket.ss_bucket.id

  policy                    = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid = "EnforceSecureTransport",
        Effect = "Deny",
        Principal = "*",
        Action = "s3:*",
        Resource = [
            aws_s3_bucket.ss_bucket.arn,
            "${aws_s3_bucket.ss_bucket.arn}/*"
        ],
        Condition = {
          Bool = {
              "aws:SecureTransport" = "false"
          }
        }
      },
      # {
      #     Sid = "EnforceSSE",
      #     Effect = "Deny",
      #     Principal = "*",
      #     Action = "s3:PutObject*",
      #     Resource = "${aws_s3_bucket.ss_bucket.arn}/*",
      #     Condition = {
      #         Null = {
      #             "s3:x-amz-server-side-encryption" = "true"
      #         }
      #     }
      # },
      {
          Sid = "DisallowPresignedURL",
          Effect = "Deny",
          Principal = "*",
          Action = "s3:GetObject",
          Resource = "${aws_s3_bucket.ss_bucket.arn}/*",
          Condition = {
              StringNotEquals = {
                "s3:authType" = "REST-HEADER"
              }
          }
      }
    ]
  })
}


resource "aws_s3_object" "churn_txt" {
  bucket                    = aws_s3_bucket.ss_bucket.id
  key                       = "dataset/churn.csv"
  source                    = "./churn.csv"
  source_hash               = filemd5("./churn.csv")
}