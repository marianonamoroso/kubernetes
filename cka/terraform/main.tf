resource "aws_instance" "node" {
  for_each               = local.ec2

  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  vpc_security_group_ids = each.value.vpc_security_group_ids
  tags                   = each.value.tags
  key_name               = aws_key_pair.k8s-key.id
  user_data              = each.value.user_data

}

