##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "us-east-1"
}

##################################################################################
# RESOURCES
##################################################################################

resource "aws_instance" "jenkins" {
  # ubuntu 16.04 hvm from https://cloud-images.ubuntu.com/locator/ec2/
  ami = "ami-d651b8ac"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.jenkins-subnet1.id}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = [
    "${aws_security_group.jenkins-sg.id}"]

  connection {
    user = "ubuntu"
    private_key = "${file(var.private_key_path)}"
  }

  #################################################
  # PROVISIONERS - ordered, don't change
  #################################################
  # Copies all files and folders in puppet/ to /tmp
  provisioner "file" {
    source = "../../data/"
    destination = "/tmp"
  }

  # install puppet, provision jenkins, create new user
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/scripts/provision.sh",
      "/tmp/scripts/provision.sh ${var.username} ${var.password}",
    ]
  }
}

resource "aws_vpc" "jenkins-vpc" {
  cidr_block = "${var.network_address_space}"
  enable_dns_hostnames = "true"

  tags {
    Name = "jenkins-vpc"
  }
}

resource "aws_internet_gateway" "jenkins-igw" {
  vpc_id = "${aws_vpc.jenkins-vpc.id}"
}

resource "aws_subnet" "jenkins-subnet1" {
  cidr_block = "${var.subnet1_address_space}"
  vpc_id = "${aws_vpc.jenkins-vpc.id}"
  map_public_ip_on_launch = "true"
}

resource "aws_route_table" "jenkins_rtb" {
  vpc_id = "${aws_vpc.jenkins-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.jenkins-igw.id}"
  }
}

resource "aws_route_table_association" "jenkins-rta-subnet1" {
  route_table_id = "${aws_route_table.jenkins_rtb.id}"
  subnet_id = "${aws_subnet.jenkins-subnet1.id}"
}

resource "aws_security_group" "jenkins-sg" {
  name = "Jenkins group"
  description = "Allow SSH inbound"
  vpc_id = "${aws_vpc.jenkins-vpc.id}"
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags {
    Name = "jenkins-sg"
  }

}
