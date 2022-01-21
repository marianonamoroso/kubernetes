resource "aws_security_group" "master-sg" {
  name        = "master-sg"
  description = "Master Node - Security Group"

  ingress {
    from_port       = 2379
    to_port         = 2380
    protocol        = "tcp"
    cidr_blocks     = ["172.31.0.0/16"]
  }

  ingress {
    from_port       = 6443
    to_port         = 6443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port       = 6783
    to_port         = 6783
    protocol        = "tcp"
    cidr_blocks     = ["172.31.0.0/16"]
    }

  ingress {
    from_port       = 10250
    to_port         = 10252
    protocol        = "tcp"
    cidr_blocks     = ["172.31.0.0/16"] 
    }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "worker-sg" {
  name        = "worker-sg"
  description = "Master Node - Security Group"

  ingress {	
    from_port       = 6783
    to_port         = 6783
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    }

  ingress {	
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    }

  ingress {	
    from_port       = 30000
    to_port         = 32767
    protocol        = "tcp"
    cidr_blocks     = ["172.31.0.0/16"]
    }

  ingress {	
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    cidr_blocks     = ["172.31.0.0/16"]
    }   
      
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
