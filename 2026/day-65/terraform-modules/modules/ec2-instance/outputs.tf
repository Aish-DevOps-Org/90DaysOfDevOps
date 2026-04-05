output "instance_id" {
    description = "ID of the ec2"
    value = aws_instance.aish_instance.id
}

output "public_ip" {
    description = "public ip of the ec2"
    value = aws_instance.aish_instance.public_ip
}

output "private_ip" {
    description = "private ip oif the ec2"
    value = aws_instance.aish_instance.private_ip
}
