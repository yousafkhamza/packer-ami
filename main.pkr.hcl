# ---------------------------------------------
# Variable declaration
# ---------------------------------------------
variable "access_key" {
  default = "AKIA5TTBRI2NQOXVGZGI"
}

variable "secret_key" {
  default = "9e2kCHJ/g1uuDpz/Z6uiaL4be4c/rkd0qh3VkJgL"
}

variable "type" {
  default = "t2.micro"
}

variable "region" {
    default = "us-east-1"
}

# -----------------------------------------------
# Timestamp variable declaration on running time
# -----------------------------------------------
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

#--------------------------------------------------
# Image Creation 
#--------------------------------------------------

source "amazon-ebs" "webserver" {
   source_ami_filter {
    filters = {
       virtualization-type = "hvm"
       name = "amzn2-ami-hvm-2.0.*.1-x86_64-ebs"
       root-device-type = "ebs"
    }
    owners = ["amazon"]
    most_recent = true
  }
  access_key         = "${var.access_key}"
  ami_name           = "packer-ami ${local.timestamp}"
  instance_type      = "${var.type}"
  region             = "${var.region}"
  secret_key         = "${var.secret_key}"
  security_group_ids = [ "sg-0c8c8b94dc5c55c1d" ]
  ssh_username       = "ec2-user"
}

build {
  sources = ["source.amazon-ebs.webserver"]
  
    provisioner "ansible" {
      playbook_file = "./play.yml"
  }

  post-processor "shell-local" {
    inline = ["echo AMI Created"]
  }
}
