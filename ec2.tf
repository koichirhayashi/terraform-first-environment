locals {
  public_key_file  = "./.key/${var.project}-key.id_rsa.pub"
  private_key_file = "./.key/${var.project}-key.id_rsa"
}

resource "tls_private_key" "keygen" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  filename = local.private_key_file
  content  = tls_private_key.keygen.private_key_pem
  provisioner "local-exec" {
    command = "chmod 600 ${local.private_key_file}"
  }
}

resource "local_file" "public_key_openssh" {
  filename = local.public_key_file
  content  = tls_private_key.keygen.public_key_openssh
  provisioner "local-exec" {
    command = "chmod 600 ${local.public_key_file}"
  }
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.project}-key"
  public_key = tls_private_key.keygen.public_key_openssh
}

/*
resource "local_file" "private_key_pem" {
  filename = local.private_key_file
  content  = tls_private_key.keygen.private_key_pem
  provisioner "local-exec" {
    command = "chmod 600 ${local.private_key_file}"
  }
}

resource "local_file" "public_key_pem" {
  filename = local.public_key_file
  content  = tls_private_key.keygen.public_key_pem
  provisioner "local-exec" {
    command = "chmod 600 ${local.public_key_file}"
  }
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.project}-key"
  public_key = tls_private_key.keygen.public_key_pem
  //public_key = file(local.public_key_file)
}
*/

resource "aws_security_group" "allow_ssh" {
  name        = "${var.project}-allow-ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.yt_live.id
}

resource "aws_security_group_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_http_ec2" {
  security_group_id = aws_security_group.allow_ssh.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  # cidr_blocks       = ["0.0.0.0/0"]
  source_security_group_id = aws_security_group.allow_http.id
}

resource "aws_security_group_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.allow_ssh.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # "-1" はすべてのプロトコルを意味します
  cidr_blocks       = ["0.0.0.0/0"]
}



resource "aws_instance" "instance" {
  ami                    = "ami-05207c56c1b903d1a"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.key_pair.key_name
  subnet_id              = aws_subnet.yk_live_public_1a.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "${var.project}-instance"
  }
  }

resource "aws_s3_bucket" "terraform_state" {
  bucket = "hayashi-terraform-state"
}
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}


