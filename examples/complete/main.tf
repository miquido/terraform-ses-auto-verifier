module "terraform-ses-auto-verifier" {
  source     = "../../"
  bucket_arn = "arn::bucket"
  bucket_id  = "ses-bucket"
  namespace  = "super-project"
  stage      = "production"
}
