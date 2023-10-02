variable "cluster_name" {
  description = "Google GKE Cluster Name"
  type        = string
}

variable "instance_group_prefix" {
  description = "The common prefix of the instance groups node names"
  type        = string
}

variable "gcp_project_id" {
  description = "The ID of the project where the GKE cluster is running within."
  type        = string
}

variable "cluster_autoscaler_helm_chart_name" {
  description = "The name of the Helm chart in the repository for cluster autoscaler."
  type        = string
  default     = "cluster-autoscaler"
}

variable "cluster_autoscaler_helm_chart_repository" {
  description = "The repository containing the cluster-autoscaler helm chart."
  type        = string
  default     = "https://kubernetes.github.io/autoscaler"
}

variable "cluster_autoscaler_helm_chart_version" {
  description = "Helm chart version for the cluster-autoscaler. See https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler for more details."
  type        = string
}

variable "cluster_autoscaler_image_version" {
  description = "The image version of must match the current GKE version up to it's minor patch, e.g. 'v1.25.0'"
  type        = string
}

variable "cluster_autoscaler_servicemonitor_enabeld" {
  description = "If true, creates a Prometheus Operator ServiceMonitor."
  type        = bool
  default     = true
}

variable "cluster_autoscaler_servicemonitor_selectors" {
  description = "ServiceMonitor labels for prometheus operator."
  type        = map(string)
  default = {
    "monitoring.syn.tools/enabled" : "true"
  }
}
