# Configure the AWS Provider - aws user "deploy"
provider "aws" {
  access_key = "${var.aws_accesskey}"
  secret_key = "${var.aws_secretkey}"
  region     = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Our default security group to access
# the instances over SSH
resource "aws_security_group" "default" {
  name        = "terraform_controller"
  description = "Used in Terraformation"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from Lisbon Office
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "master" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    # for Ubuntu=ubuntu for RedHat=ec2-user
    user = "ec2-user"

    agent = false
  }

  count                  = 1
  instance_type          = "t2.micro"                                # Instance size
  ami                    = "${lookup(var.aws_amis, var.aws_region)}" # Lookup the correct AMI based on the region we specified
  key_name               = "${aws_key_pair.auth.id}"                 # The name of our SSH keypair we created above.
  vpc_security_group_ids = ["${aws_security_group.default.id}"]      # Our Security group to allow SSH access
  subnet_id              = "${aws_subnet.default.id}"                # Our subnet

  tags {
    Name        = "controller-${format("%02d", count.index + 1)}"
    Environment = "dev"
    TF          = "yes"
  }

  # Output inventory file for Ansible outside terraform folder
  provisioner "local-exec" {
    command = "echo '[dev]\n${aws_instance.master.tags.Name} ansible_host=${aws_instance.master.public_ip} ansible_user=ec2-user\n' > ../.inventory"
  }

  # Output Terraform vars for Jenkins
  provisioner "local-exec" {
    command = "echo 'controller_vpc = \"${aws_internet_gateway.default.vpc_id}\" \ncontroller_subnet = \"${aws_instance.master.subnet_id}\"' > controller.tfvars"
  }
}
