# getting latest Amazon Linux2 AMI.
data "aws_ami" "getami" {
  most_recent = "true"
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# Creating SSH keypair for EC2 and passing public key to be stored in EC2.
resource "aws_key_pair" "sshkeys" {
  key_name = "ec2ssh"
  public_key = file("id_rsa.pub")
}

# lauching EC2 instance
resource "aws_instance" "ec2" {
  ami = data.aws_ami.getami.id
  instance_type = "t2.micro"
  count = var.public-subnet-counts
  associate_public_ip_address = "true"
  key_name = "ec2ssh"
  #iam_instance_profile = aws_iam_instance_profile.iprofile.name
  subnet_id = aws_subnet.public-subnet.*.id[count.index]
  vpc_security_group_ids = [aws_security_group.sgiac.id]

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y httpd",
      "sudo systemctl start httpd",
      "sudo chmod 777 -R /var/",
      "echo $HOSTNAME >> /var/www/html/index.html"
      ]

   connection {
     type = "ssh"
     user = "ec2-user"
     private_key = file("id_rsa")
     host = self.public_ip
   }
  }
}

# creating Security Group
resource "aws_security_group" "sgiac" {
  name = "sgiacdynamic"
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.sgports
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ec2" {
  value = aws_instance.ec2.*.id
}
output "Security_Group_ID" {
  value = aws_security_group.sgiac.id
}
output "ami" {
  value = data.aws_ami.getami.id
}
