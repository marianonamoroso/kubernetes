resource "aws_key_pair" "k8s-key" {
  key_name   = "k8s-node"
  public_key = ""
}