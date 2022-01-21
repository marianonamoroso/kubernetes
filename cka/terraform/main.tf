resource "aws_instance" "node" {
  for_each               = local.ec2

  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  vpc_security_group_ids = each.value.instance_type == "t2.medium" ? [aws_security_group.master-sg.id] : [aws_security_group.worker-sg.id]

  tags = {
    deployment  = "TF"
    cert        = "CKA"
    author      = "MA"
  }
}
