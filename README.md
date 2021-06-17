# Packer Golden Image Builder (AWS)
[![Builds](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

---

## Description
Packer is a tool for build a golden images also packer is lightwight. As of here, I have used to provision the image using a ansible script and who you guys use this additional options like shell. 

----
## Feature

- Easy to build a image with a lightweight code 
- You can integrate this with automation jenkins (Architacutre included with jenkins)

-----

### Pre-Requests
- Need a IAM user with ec2 access 

-----
### How to install packer on your machine
Reference: [packer download](https://www.packer.io/downloads)
```sh
wget https://releases.hashicorp.com/packer/1.7.3/packer_1.7.3_linux_amd64.zip
unzip packer_1.7.3_linux_amd64.zip
mv packer /usr/bin/
```
Check packer version using
```sh
packer version
```
----

### How to use

```sh
yum install git -y
amazon-linux-extras install ansible2  <------- (optional when you use)
git clone https://github.com/yousafkhamza/packer-ami.git
cd packer-ami
packer build main.pkr.hcl
```
-----
### Behind the file
vim main.pkr.hcl
```sh
# ---------------------------------------------
# Variable declaration
# ---------------------------------------------
variable "access_key" {
  default = "<your access key>"
}

variable "secret_key" {
  default = "<your secret key>"
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
```
----
vim play.yml (Image provision using ansible)
```sh
---
- name: 'Provision Image'
  hosts: localhost
  gather_facts: false
  become: true
  vars:
    - git_url: "https://github.com/yousafkhamza/aws-elb-site.git"
  tasks:
    - name: "install Apache"
      yum:
        name:
          - httpd
        state: present

    - name: "Service start"
      service:
        name: httpd
        state: restarted
        enabled: true

    - name: "Cloning Git Repository"
      git:
        repo: "{{ git_url }}"
        dest: /var/website/

    - name: "Copy from /var/website to /var/www/html/"
      copy:
        src: /var/website/
        dest: /var/www/html/
        owner: apache
        group: apache
        remote_src: true
```

## Conclusion
It's just build a golden image.

_by_
_yousaf k hamza_
