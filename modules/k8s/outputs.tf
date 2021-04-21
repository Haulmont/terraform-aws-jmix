output "endpoint" {
  value = module.eks.cluster_endpoint
}

output "ca_certificate" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_id" {
  value = module.eks.cluster_id
}