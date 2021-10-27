output "region" {
    description = "Region server will be created in"
    value       = "${aws_instance.minecraft_server.region}"
}