locals {
    user_data = {
    #user_data for worker node    
        master = <<USERDATA
        #!/bin/bash
        hostnamectl set-hostname master
	    /etc/init.d/hostname.sh start
    USERDATA

    #user_data for worker-1 node
        worker-1 = <<USERDATA
        #!/bin/bash
        hostnamectl set-hostname worker-1
	    /etc/init.d/hostname.sh start
    USERDATA

    #user_data for worker-2 node
        worker-2 = <<USERDATA
        #!/bin/bash
        hostnamectl set-hostname worker-2
	    /etc/init.d/hostname.sh start
    USERDATA
    }

    ec2 = {
        master-node = {
        ami                    = "ami-04505e74c0741db8d"
        instance_type          = "t2.medium"
        user_data              = base64encode(format(local.user_data["master"]))
        vpc_security_group_ids = [aws_security_group.master-sg.id]

        tags = {
                Name        = "master-node"
                Deployment  = "TF"
                Cert        = "CKA"
                Author      = "MA"
            }  

        }
        worker-node-1 = {
        ami                    = "ami-04505e74c0741db8d"
        instance_type          = "t2.large"
        user_data              = base64encode(format(local.user_data["worker-1"]))
        vpc_security_group_ids = [aws_security_group.worker-sg.id]

        tags = {
                Name        = "worker-node-1"
                Deployment  = "TF"
                Cert        = "CKA"
                Author      = "MA"
            }

        }
        worker-node-2 = {
        ami                    = "ami-04505e74c0741db8d"
        instance_type          = "t2.large"
        user_data              = base64encode(format(local.user_data["worker-2"]))
        vpc_security_group_ids = [aws_security_group.worker-sg.id]

        tags = {
                Name        = "worker-node-2"
                Deployment  = "TF"
                Cert        = "CKA"
                Author      = "MA"
            }
            
        }
    }
}    
