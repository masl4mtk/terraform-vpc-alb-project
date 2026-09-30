output "subnet_ids" {
    value = [
        aws_subnet.terraform-project-subnet-1.id,
        aws_subnet.terraform-project-subnet-2.id
    ]
    }

output "instance_security_group_id" {
    value = aws_security_group.instance_sg.id
    }


output "vpc_id" {
    value = aws_vpc.terraform-project-vpc.id
    }


output "alb_security_group_id" {
    value = aws_security_group.alb_sg.id
    }