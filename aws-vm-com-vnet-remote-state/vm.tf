data "aws_ami" "debian" {
  most_recent = true

  owners = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "terraform" {
  key_name   = "terraform-key"
  public_key = file("./id_rsa.pub")
}

resource "aws_eip" "public_ip" {
  domain = "vpc"

  tags = local.common_tags
}

resource "aws_network_interface" "network_interface" {
  subnet_id = data.terraform_remote_state.vpc.outputs.subnet_id

  security_groups = [
    data.terraform_remote_state.vpc.outputs.security_group_id
  ]

  tags = local.common_tags
}

resource "aws_eip_association" "eip_association" {
  allocation_id        = aws_eip.public_ip.id
  network_interface_id = aws_network_interface.network_interface.id
}

resource "aws_instance" "vm" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro"

  primary_network_interface {
    network_interface_id = aws_network_interface.network_interface.id
  }

  key_name = aws_key_pair.terraform.key_name

  root_block_device {
    volume_type = "gp3"
    volume_size = 64
  }

  tags = merge(local.common_tags, {
    Name = "aws-vm"
  })
}