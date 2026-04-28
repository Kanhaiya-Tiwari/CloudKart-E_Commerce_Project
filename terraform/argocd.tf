# ============================================================
# ARGOCD — Installed via Helm
# ============================================================
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.18"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }

  set {
    name  = "server.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "server.resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "server.resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "server.resources.limits.memory"
    value = "512Mi"
  }

  depends_on = [module.eks, kubernetes_namespace.argocd]
}

# ============================================================
# UPDATE KUBECONFIG & LOGIN TO ARGOCD
# ============================================================
resource "null_resource" "argocd_login" {
  triggers = {
    argocd_release_id = helm_release.argocd.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Update kubeconfig
      aws eks update-kubeconfig --region ${local.region} --name ${local.name}

      # Wait for ArgoCD server to be ready
      kubectl wait --for=condition=available deployment/argocd-server \
        -n argocd --timeout=300s || true

      # Extract admin password
      ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
        -o jsonpath="{.data.password}" | base64 --decode 2>/dev/null || echo "waiting")

      echo "ArgoCD is ready. Password: $ARGOCD_PASSWORD"
    EOT
  }

  depends_on = [helm_release.argocd]
}

# ============================================================
# APP-OF-APPS — cloudkart-cluster Application
# ============================================================
resource "kubectl_manifest" "argocd_app_of_apps" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name       = "cloudkart-cluster"
      namespace  = "argocd"
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      project = "default"

      source = {
        repoURL        = var.github_repo_url
        targetRevision = "HEAD"
        path           = "kubernetes"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "cloudkart"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true",
          "PruneLast=true"
        ]
        retry = {
          limit = 5
          backoff = {
            duration    = "5s"
            factor      = 2
            maxDuration = "3m"
          }
        }
      }
    }
  })

  depends_on = [
    helm_release.argocd,
    kubernetes_namespace.cloudkart
  ]
}
