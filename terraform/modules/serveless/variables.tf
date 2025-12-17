variable "project_name" {
  type = string
}

variable "iam_role_arn" {
  description = "ARN da Role que o Lambda irá assumir"
  type        = string
}

variable "image_uri" {
  description = "URI da imagem Docker no ECR"
  type        = string
}

variable "bucket_id" {
  description = "ID do bucket para configurar o Trigger"
  type        = string
}

variable "bucket_arn" {
  description = "ARN do bucket para permissões de invocação"
  type        = string
}