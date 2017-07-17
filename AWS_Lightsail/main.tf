# Configure the AWS Provider - aws user "deploy"
provider "aws" {
  access_key = "${var.aws_accesskey}"
  secret_key = "${var.aws_secretkey}"
  region     = "${var.aws_region}"
}

# Import an existing public key
resource "aws_lightsail_key_pair" "lg_key_pair" {
  name       = "${var.key_name}"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

# Create a new GitLab Lightsail Instance
resource "aws_lightsail_instance" "instance" {
  name                = "webserver-01"
  availability_zone   = "us-east-1b"
  bundle_id           = "nano_1_0"
  blueprint_id        = "ubuntu_16_04"
  key_pair_name       = "${aws_lightsail_key_pair.lg_key_pair.name}"
}
