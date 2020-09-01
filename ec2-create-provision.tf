terraform {
  backend "s3" {
    bucket = "cf-sales-dev-tf-state-files"
    key    = "aws-spring-boot-deploy/key"
    region = "us-west-2"
  }
}

provider "aws" {}

variable private_key_path{
  description = "Path to the SSH private key to be used for authentication"
  default = "./private.pem"
}

resource "aws_security_group" "aws_cf_tf" {
  name        = "aws_cf_tf"
  description = "Used in the terraform"
  vpc_id      = "vpc-02c5dbe54afc8ed28"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Java application access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the internet
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "aws_cf_tf" {
  ami = "ami-09211c0443ccbcb9e"
  instance_type = "t3.micro"

  key_name = "aws-cf-tf"

  vpc_security_group_ids = ["${aws_security_group.aws_cf_tf.id}"]

  subnet_id = "subnet-0226033eab8e4f954"

  depends_on = [
  # Security Group must exist.
    aws_security_group.aws_cf_tf
  ]

}

resource "aws_eip" "aws_cf_tf" {
  vpc = true

  instance                  = aws_instance.aws_cf_tf.id
  associate_with_private_ip = aws_instance.aws_cf_tf.private_ip

  connection {
    # The default username for our AMI
    user = "ubuntu"
    type = "ssh"
    private_key = file(var.private_key_path)
    host = aws_eip.aws_cf_tf.public_ip
    # The connection will use the local SSH agent for authentication.
  } 

  # install java, create dir
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "mkdir -p /usr/share/man/man1",
      "sudo apt-get -y install openjdk-8-jre-headless"
    ]
  }

  # upload jar file
  provisioner "file" {
    source      = "/codefresh/volume/spring-boot-application.jar"
    destination = "/home/ubuntu/spring-boot-application.jar"
  }

  # run jar
  provisioner "remote-exec" {
    inline = [
      "nohup java -Djava.security.egd=file:/dev/./urandom -Dserver.port=8080 -Dserver.host=http://${aws_eip.aws_cf_tf.public_ip} -jar /home/ubuntu/spring-boot-application.jar &; disown"
    ]
  }

  depends_on = [
  # Instance must exist.
    aws_instance.aws_cf_tf
  ]

}

output "instance_ip_addr" {
  value       = aws_eip.aws_cf_tf.public_ip
  description = "The public IP address of the main server instance."
  depends_on = [
  # Instance must exist.
    aws_eip.aws_cf_tf
  ]
}
