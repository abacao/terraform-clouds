provider "digitalocean" {
  #DIGITALOCEAN_TOKEN = "${var.do_token}"
  # You need to set this in your .bashrc
  # export DIGITALOCEAN_TOKEN="Your API TOKEN"
  #
}

resource "digitalocean_tag" "abacao" {
  name = "abacao"
}

resource "digitalocean_droplet" "devops" {
  # Obtain your ssh_key id number via your account. See Document https://developers.digitalocean.com/documentation/v2/#list-all-keys
  count              = 1
  ssh_keys           = [4644534]         # Key example
  image              = "${var.centos}"
  region             = "${var.do_lon1}"
  size               = "1gb"
  private_networking = false
  backups            = false
  ipv6               = false
  name               = "ranker-terra-${format(count.index + 1)}"
  tags = [
    "${digitalocean_tag.abacao.id}",
  ]

    connection {
      type     = "ssh"
      private_key = "${file("~/.ssh/id_rsa")}"
      user     = "root"
      timeout  = "3m"
    }

  # Pause
  provisioner "local-exec" {
    command = "sleep 30"
  }

  # Output inventory file for Ansible outside terraform folder
  provisioner "local-exec" {
    command = "echo '[dev]\n${digitalocean_droplet.devops.name} ansible_host=${digitalocean_droplet.devops.ipv4_address}' > ../.inventory"
  }

  # Ansible Run
  provisioner "local-exec" {
    command = "ansible-playbook -i ../.inventory ../playbooks/server.yml -vv"
  }

  # Show off
  provisioner "local-exec" {
    command = "open http://${digitalocean_droplet.devops.ipv4_address}"
  }
}
