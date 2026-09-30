resource "aws_vpc" "terraform-project-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "terraform-project-vpc"
  }
}

resource "aws_subnet" "terraform-project-subnet-1" {
    vpc_id                  = aws_vpc.terraform-project-vpc.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-east-1a"  
    map_public_ip_on_launch = true

    tags = {    
     Name = "terraform-project-subnet-1"
  }
}   

resource "aws_subnet" "terraform-project-subnet-2" {
    vpc_id                  = aws_vpc.terraform-project-vpc.id
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "us-east-1b"
    map_public_ip_on_launch = true
   
   tags = {    
     Name = "terraform-project-subnet-2"
    }       
}

resource "aws_internet_gateway" "terraform-project-igw" {
  vpc_id = aws_vpc.terraform-project-vpc.id

  tags = {
    Name = "terraform-project-igw"
  }
}

resource "aws_route_table" "terraform-project-rt" {
  vpc_id = aws_vpc.terraform-project-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-project-igw.id
    }

    tags = {
        Name = "terraform-project-rt"
    }
}

resource "aws_route_table_association" "terraform-project-rta-1" {
  subnet_id      = aws_subnet.terraform-project-subnet-1.id
  route_table_id = aws_route_table.terraform-project-rt.id
}

resource "aws_route_table_association" "terraform-project-rta-2" {
  subnet_id      = aws_subnet.terraform-project-subnet-2.id
  route_table_id = aws_route_table.terraform-project-rt.id
}

resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "Security group for instance"
  vpc_id      = aws_vpc.terraform-project-vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.alb_sg.id]
        }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.terraform-project-vpc.id
    
ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
}