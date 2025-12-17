module "storage" {
  source      = "./modules/storage"
  bucket_name = "enacom-csv-processor-${var.project_name}" 
}

module "identity" {
  source           = "./modules/identity"
  project_name     = var.project_name
  bucket_arn       = module.storage.bucket_arn
}

module "serveless" {
  source           = "./modules/serveless"
  project_name     = var.project_name
  iam_role_arn     = module.identity.lambda_role_arn
  bucket_id        = module.storage.bucket_id
  bucket_arn       = module.storage.bucket_arn
  image_uri        = "${module.serveless.repository_url}:latest" 
}