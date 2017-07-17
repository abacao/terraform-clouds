output "Creation Date" {
  value = "${aws_lightsail_instance.instance.created_at}"
}

output "username" {
  value = "${aws_lightsail_instance.instance.username}"
}

output "name" {
    value = "${aws_lightsail_instance.instance.name}"
}

# Seems that it wasn't still implemented.
// output "ip" {
//     value = "${aws_lightsail_instance.public_ip_address}"
// }

// output "priv_ip" {
//     value = "${aws_lightsail_instance.private_ip_address}"
// }
