resource "helm_release" "aws-node-termination-handler" {
  name       = "aws-node-termination-handler"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-node-termination-handler"

  set{
    name  = "serviceAccount.name"
    value = "iamserviceaccount-${var.name_prefix}aws-node-termination-handler"
  }
}
