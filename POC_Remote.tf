variable my_public_key{
  type = string
}

resource "null_resource" "remote" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.my_public_key
    host        = aws_instance.instance.public_ip
    timeout     = "4m"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd.x86_64",
      "sudo systemctl start httpd.service",
      "sudo systemctl enable httpd.service",
      "sudo yum install git -y",
      "sudo git clone https://github.com/Purna88836/my-portfolio /var/www/html"

    ]
  }
}