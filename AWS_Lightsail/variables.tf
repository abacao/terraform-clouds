variable "key_name" {
  description = <<DESCRIPTION
Desired name of AWS key pair

Example: abacao
DESCRIPTION
}

variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/id_rsa.pub
DESCRIPTION
}


variable "aws_accesskey" {
  description = <<DESCRIPTION
Provide your AWS access key

Example: AAAAAAAAAAAAAAAAAAAA
DESCRIPTION
}

variable "aws_secretkey" {
  description = <<DESCRIPTION
Provide your AWS secret key

Example: phckiubeetx!dsakjhdangs"dczlnd
DESCRIPTION
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-2"
}

# Red Hat Enterprise Linux 7.3 (HVM), SSD Volume Type
variable "aws_amis" {
  default = {
    #eu-west-2 = "ami-ede2e889" #ubuntu for testing
    eu-west-2 = "ami-9c363cf8" # London
    eu-central-1 = "ami-e4c63e8b" # Frankfurt
    eu-west-1 = "ami-02ace471" # Ireland
  }
}
