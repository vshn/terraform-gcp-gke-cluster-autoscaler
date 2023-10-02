resource "google_service_account" "k8s_autoscaler_service_account" {
  account_id   = "k8s-cluster-autoscaler"
  display_name = "K8S Cluster Autoscaler"
}

resource "google_project_iam_member" "k8s_autoscaler_service_account_role_binding" {
  project = var.gcp_project_id
  role    = "roles/compute.instanceAdmin.v1"

  members = [
    "serviceAccount:k8s-cluster-autoscaler@${var.gcp_project_id}.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "k8s_autoscaler_binding" {
  project = var.gcp_project_id
  role    = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.gcp_project_id}.svc.id.goog[kube-system/cluster-autoscaler-gce-cluster-autoscaler]",
  ]
}
resource "kubernetes_labels" "kube_system_monitoring" {
  count = var.cluster_autoscaler_servicemonitor_enabeld ? 1 : 0

  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "kube-system"
  }
  labels = {
    "monitoring.syn.tools/infra" = "true"
  }
}

resource "helm_release" "cluster_autoscaler" {
  atomic          = true
  chart           = var.cluster_autoscaler_helm_chart_name
  cleanup_on_fail = true
  name            = var.cluster_autoscaler_helm_chart_name
  namespace       = "kube-system"
  repository      = var.cluster_autoscaler_helm_chart_repository
  timeout         = 600
  version         = var.cluster_autoscaler_helm_chart_version

  values = [
    yamlencode({
      "autoDiscovery" : {
        "clusterName" : var.cluster_name,
      }
      "cloudProvider" : "gce"
      "autoscalingGroupsnamePrefix": [
        {
          "name": var.instance_group_prefix,
          "maxSize": 3,
          "minSize": 1
        }
      ]
      "extraArgs" : {
        "leader-elect" : false
      }
      "image" : {
        "tag" : var.cluster_autoscaler_image_version
        }
      "rbac" : {
        "serviceAccount" : {
          "annotations" : {
            "iam.gke.io/gcp-service-account" : module.cluster_autoscaler_iam_service_acount.service_account_name
          },
          "create" : true,
          "name" : "cluster-autoscaler",
          "automountServiceAccountToken" : true
        }
      }
      "replicaCount" : "1"
      "resources" : {
        "limits" : {
          "cpu" : "100m",
          "memory" : "500Mi"
        },
        "requests" : {
          "cpu" : "100m",
          "memory" : "500Mi"
        }
      }
      "serviceMonitor" : {
        "enabled" : var.cluster_autoscaler_servicemonitor_enabeld
        "namespace" : "kube-system"
        "selector" : var.cluster_autoscaler_servicemonitor_selectors
      }
    })
  ]
}
