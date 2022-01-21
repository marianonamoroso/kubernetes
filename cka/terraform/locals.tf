locals {
    ec2 = {
        master-node   = {
        ami           = "ami-04505e74c0741db8d"
        instance_type = "t2.medium"
        }
        worker-node-1 = {
        ami           = "ami-04505e74c0741db8d"
        instance_type = "t2.large"
        }
        worker-node-2 = {
        ami           = "ami-04505e74c0741db8d"
        instance_type = "t2.large"
        }
    }
}    
