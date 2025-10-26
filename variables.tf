variable "region" {
  type        = string
  description = "Region for the GKE cluster"
}
variable "project_id" {
  type        = string
  description = "GCP project ID"
}
variable "network_tier" {
  description = "Network tier for GKE cluster (STANDARD or PREMIUM)"
  type        = string
  default     = "STANDARD"
}
variable "ssh_whitelist" {
  description = "List of IPs/subnets allowed to access ovefr ssh."
  type        = list(string)
}
variable "public_access_enabled" {
  description = "Enable public access to the cluster workloads ingress."
  type        = bool
  default     = false
}
variable "dev_whitelist" {
  description = "List of IPs/subnets allowed to access dev services/load balancers."
  type        = list(string)
}
variable "proxy_subnet_cidr" {
    description = "CIDR for the proxy subnet."
    type        = string
}