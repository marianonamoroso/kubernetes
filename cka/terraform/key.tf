resource "aws_key_pair" "k8s-key" {
  key_name   = "k8s-ssh"
  public_key = "<YOUR_SSH_PUBLIC_KEY>" # ssh-keygen -y -f key.pem > key.pub
}