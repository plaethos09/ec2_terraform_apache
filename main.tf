provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${var.key_name}.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apt-utils",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y apache2",
    ]
  }

  provisioner "file" {
    source      = "scripts/install-mysql.sh"
    destination = "/tmp/install-mysql.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-mysql.sh",
      "sudo /tmp/install-mysql.sh",
    ]
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}

