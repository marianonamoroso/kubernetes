resource "aws_key_pair" "k8s-key" {
  key_name   = "k8s-ssh"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCWRZIl2tB4qrryuggWIy388oPg7e5d4YDcw7r6J8D/TCvBNUtKlsO7Wseb5GxwB4HbUSuuXU/kvjZbu593kee1H6pq00PXW28sIDepdzYY/HYUI6azX2jO1kuWg6Fy6MaqOvzj68vhfOSnfwzTY4TyTJJr1lJ0BHNATA9bSzZZrjQDWnYPsp/qvwzV4YZ4GjfOSaovEYH4lgbi2/jfwqXDLsbYFVXTtwsVn34Rly1oiUGE8dxQxyG6GAlLJ/tryMAm+Z5Yzni/dGFiIO0n4/eC9o2lYKXtRtzTo3G1z6UALrfywUVLWpYPrOV8MwpL+n5zDzR4ctTzqVjdhaayd5cL" # ssh-keygen -y -f key.pem > key.pub
}