# ============================================================
# KUBERNETES NAMESPACES
# ============================================================
resource "kubernetes_namespace" "monitoring" {
  metadata { name = "monitoring" }
  depends_on = [module.eks]
}

resource "kubernetes_namespace" "argocd" {
  metadata { name = "argocd" }
  depends_on = [module.eks]
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata { name = "ingress-nginx" }
  depends_on = [module.eks]
}

resource "kubernetes_namespace" "cert_manager" {
  metadata { name = "cert-manager" }
  depends_on = [module.eks]
}

resource "kubernetes_namespace" "cloudkart" {
  metadata {
    name = "cloudkart"
  }
  depends_on = [module.eks]
}

# ============================================================
# INGRESS-NGINX
# ============================================================
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.1"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name

  values = [
    <<-EOT
    controller:
      service:
        type: LoadBalancer
      resources:
        requests:
          cpu: 100m
          memory: 128Mi
        limits:
          cpu: 500m
          memory: 512Mi
    EOT
  ]

  depends_on = [module.eks]
}

# ============================================================
# CERT-MANAGER
# ============================================================
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.14.5"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name

  values = [
    <<-EOT
    installCRDs: true
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
      limits:
        cpu: 200m
        memory: 256Mi
    EOT
  ]

  depends_on = [helm_release.ingress_nginx]
}

# ============================================================
# KUBE-PROMETHEUS-STACK (Grafana + Prometheus + Alertmanager)
# ============================================================
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "58.7.2"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    <<-EOT
    grafana:
      sidecar:
        dashboards:
          enabled: true
      ingress:
        enabled: true
        ingressClassName: nginx
      additionalDataSources:
        - name: Loki
          type: loki
          url: http://loki-stack.monitoring.svc.cluster.local:3100
          access: proxy
          isDefault: false
      resources:
        requests:
          memory: 128Mi
        limits:
          memory: 256Mi
    prometheus:
      prometheusSpec:
        enableRemoteWriteReceiver: true
        storageSpec:
          volumeClaimTemplate:
            spec:
              accessModes:
                - ReadWriteOnce
              resources:
                requests:
                  storage: 10Gi
        resources:
          requests:
            memory: 512Mi
          limits:
            memory: 1Gi
    EOT
  ]

  depends_on = [module.eks, kubernetes_namespace.monitoring]
}

# ============================================================
# LOKI-STACK (Loki + Promtail)
# ============================================================
resource "helm_release" "loki_stack" {
  name       = "loki-stack"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  version    = "2.10.2"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    <<-EOT
    promtail:
      enabled: true
    loki:
      persistence:
        enabled: true
        size: 10Gi
      resources:
        requests:
          memory: 128Mi
        limits:
          memory: 512Mi
    EOT
  ]

  depends_on = [helm_release.kube_prometheus_stack]
}

# ============================================================
# OPENTELEMETRY COLLECTOR
# ============================================================
resource "helm_release" "opentelemetry_collector" {
  name       = "opentelemetry-collector"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  version    = "0.90.0"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    <<-EOT
    mode: daemonset
    image:
      repository: otel/opentelemetry-collector-contrib
    config:
      exporters:
        logging: {}
        loki:
          endpoint: "http://loki-stack.monitoring.svc.cluster.local:3100/loki/api/v1/push"
        prometheusremotewrite:
          endpoint: "http://kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090/api/v1/write"
          tls:
            insecure: true
      service:
        pipelines:
          traces:
            receivers: [otlp]
            exporters: [logging]
          metrics:
            receivers: [otlp]
            exporters: [logging, prometheusremotewrite]
          logs:
            receivers: [otlp]
            exporters: [logging, loki]
    resources:
      requests:
        cpu: 50m
        memory: 64Mi
      limits:
        cpu: 200m
        memory: 256Mi
    EOT
  ]

  depends_on = [helm_release.loki_stack]
}

# ============================================================
# SONARQUBE (Required by Jenkins pipeline for SAST)
# ============================================================
resource "kubernetes_namespace" "sonarqube" {
  metadata { name = "sonarqube" }
  depends_on = [module.eks]
}

resource "helm_release" "sonarqube" {
  name       = "sonarqube"
  repository = "https://SonarSource.github.io/helm-chart-sonarqube"
  chart      = "sonarqube"
  version    = "2025.4.6"
  namespace  = kubernetes_namespace.sonarqube.metadata[0].name
  timeout    = 600

  values = [
    <<-EOT
    community:
      enabled: true
    monitoringPasscode: "{233310410117411710110521141002021001120220011511120211624312032112115114115}"
    service:
      type: LoadBalancer
    persistence:
      enabled: true
      size: 10Gi
    resources:
      requests:
        cpu: 200m
        memory: 512Mi
      limits:
        cpu: 800m
        memory: 2Gi
    EOT
  ]

  depends_on = [module.eks, kubernetes_namespace.sonarqube, helm_release.kube_prometheus_stack]
}
