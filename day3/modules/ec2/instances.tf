resource "aws_instance" "instance1" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = var.subnet_id_public
  tags = {
      Name = "ec2-module-1"
  }
}

resource "aws_instance" "instance2" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = var.subnet_id_private
  tags = {
      Name = "ec2-module-2"
  }
}