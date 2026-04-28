# ============================================================
# INFRASTRUCTURE OUTPUTS
# ============================================================
output "region" {
  description = "AWS region where resources are deployed"
  value       = local.region
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

# ============================================================
# EKS CLUSTER OUTPUTS
# ============================================================
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_ca_certificate" {
  description = "Base64 encoded EKS cluster CA certificate"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_node_group_public_ips" {
  description = "Public IPs of EKS worker nodes"
  value       = data.aws_instances.eks_nodes.public_ips
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${local.region} --name ${module.eks.cluster_name}"
}

# ============================================================
# JENKINS EC2 OUTPUTS
# ============================================================
output "jenkins_public_ip" {
  description = "Public IP of Jenkins EC2 instance"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_ssh_command" {
  description = "SSH command to access Jenkins"
  value       = "ssh -i cloudkart-key ubuntu@${aws_instance.jenkins.public_ip}"
}

output "jenkins_url" {
  description = "Jenkins UI URL"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

# ============================================================
# HELM & KUBERNETES DEPLOYMENTS (from terraform/helm.tf)
# ============================================================
output "argocd_admin_password_command" {
  description = "Command to retrieve ArgoCD admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode"
}

output "ingress_nginx_load_balancer" {
  description = "Get Ingress-NGINX LoadBalancer URL"
  value       = "kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "grafana_admin_password_command" {
  description = "Command to retrieve Grafana admin password"
  value       = "kubectl get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 --decode"
}

output "prometheus_url" {
  description = "Get Prometheus LoadBalancer URL"
  value       = "kubectl get svc --namespace monitoring kube-prometheus-stack-prometheus -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

# ============================================================
# NEXT STEPS
# ============================================================
output "deployment_instructions" {
  description = "Instructions for deploying CloudKart"
  value       = <<-EOT
    
    ✓ Infrastructure created! Now follow these steps:

    1. Update kubeconfig:
       aws eks update-kubeconfig --region eu-west-1 --name cloudkart-eks-cluster

    2. Wait for all nodes to be ready:
       kubectl get nodes

    3. Verify all Helm releases:
       helm list -a --all-namespaces

    4. Get ArgoCD admin password:
       kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode

    5. Access ArgoCD:
       kubectl port-forward svc/argocd-server -n argocd 8443:443

    6. View CloudKart deployment:
       kubectl get deployments -n cloudkart
       kubectl logs -f deployment/cloudkart -n cloudkart

    7. Get Ingress URL:
       kubectl get ingress -n cloudkart

    For more details, check terraform outputs above.
  EOT
}

output "sonarqube_url" {
  description = "Get SonarQube LoadBalancer URL (admin/admin on first login)"
  value       = "kubectl get svc -n sonarqube sonarqube-sonarqube -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}
