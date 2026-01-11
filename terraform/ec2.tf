resource "aws_instance" "ec2_1" {
  ami                         = "ami-02b8269d5e85954ef"
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet1.id
  vpc_security_group_ids      = [aws_security_group.SG.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io curl
              systemctl enable --now docker
              curl -SL "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              usermod -aG docker ubuntu
              newgrp docker
              EOF
}

resource "aws_instance" "ec2_2" {
  ami                         = "ami-02b8269d5e85954ef"
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet2.id
  vpc_security_group_ids      = [aws_security_group.SG.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io curl
              systemctl enable --now docker
              curl -SL "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              usermod -aG docker ubuntu
              newgrp docker
              EOF
}

resource "aws_eip_association" "attach_existing_eip_1" {
  instance_id   = aws_instance.ec2_1.id
  allocation_id = "eipalloc-048497ecf947f7fda" 

  depends_on = [aws_instance.ec2_1]
}

resource "aws_eip_association" "attach_existing_eip_2" {
  instance_id   = aws_instance.ec2_2.id
  allocation_id = "eipalloc-05dd6c9d7c04fb28c" 

  depends_on = [aws_instance.ec2_2]
}
