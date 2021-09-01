module "terraform-ses-auto-verifier" {
  source     = "../../"
  bucket_arn = "arn::bucket"
  bucket_id  = "ses-bucket"
  namespace  = "super-project"
  stage      = "production"
  mail_s3_bucket_prefix = "emails/bounces/example.com"
}
