output "Instance Names" {
  value = "${join(" ", google_compute_instance.abacao-instance.*.name)}"
}

output "Instance Public IPs" {
  value = "${join(" ", google_compute_instance.abacao-instance.*.network_interface.0.access_config.0.assigned_nat_ip)}"
}

output "Instance Private IPs" {
  value = "${join(" ", google_compute_instance.abacao-instance.*.network_interface.0.address)}"
}
