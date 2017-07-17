###
output "Public ip" {
  value = "${digitalocean_droplet.devops.ipv4_address}"
}

output "Name" {
  value = "${digitalocean_droplet.devops.name}"
}
