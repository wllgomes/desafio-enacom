output "ecr_url" {
  value = module.serveless.repository_url
}

output "bucket_input" {
  value = module.storage.bucket_id
}