data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}


resource "aws_instance" "terraform-project-instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = var.subnet_ids[0]
    vpc_security_group_ids = [var.security_group]

user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y docker git
                systemctl start docker
                systemctl enable docker
                git clone https://github.com/masl4mtk/docker-demo-app
                cd docker-demo-app
                docker build -t app .
                docker run -d -p 80:80 app

              EOF

  tags = {
    Name = "terraform-project-instance"
  }
}

