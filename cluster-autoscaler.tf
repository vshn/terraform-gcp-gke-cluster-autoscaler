module "cluster_autoscaler_iam_service_account" {
  source  = "terraform-google-modules/iam/google"
  version = "7.7.0"

  role_name                        = format("%s-cluster-autoscaler-role", var.cluster_name)
  role_description                 = format("Allows %s assume role permissions in %s", var.cluster_name, var.region)
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [var.cluster_name]

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
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
      "extraArgs" : {
        "leader-elect" : false
      }
      "image" : {
        "tag" : var.image_ve
        }
      "rbac" : {
        "create" : true,
        "pspEnabled" : true,
        "serviceAccount" : {
          "annotations" : {
            "iam.gke.io/gcp-service-account" : module.cluster_autoscaler_iam_service_acount.
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
