output "name" {
    value = "${aws_instance.master.tags.Name}"
}

output "ip" {
    value = "${aws_instance.master.public_ip}"
}
