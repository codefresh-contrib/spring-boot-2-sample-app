provider "aws" {}

variable sftp_batch_path {
  description = "Path do sftp batch file"
  default = "~/sftp_batchfile"
}

provider "aws" {
  region = "us-west-2"
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
  ami = "ami-060cde69"
  instance_type = "t2.micro"

  key_name = "aws-cf-tf"

  vpc_security_group_ids = ["vpc-02c5dbe54afc8ed28"]


  connection {
    # The default username for our AMI
    user = "ubuntu"
    type = "ssh"
    private_key = "${file(var.private_key_path)}"
    # The connection will use the local SSH agent for authentication.
  }

  # install java, create dir
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
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
      "java -Djava.security.egd=file:/dev/./urandom -jar /app/spring-boot-application.jar",
    ]
  }

  # download logFile results
  provisioner "local-exec" {
    command =
    "sftp -b ${var.sftp_batch_path} -i ${var.private_key_path} -o StrictHostKeyChecking=no ubuntu@${aws_instance.aws_cf_tf.public_dns}"
  }


}


