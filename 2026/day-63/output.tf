output "vpc_id" {
  description = "ID of VPC"
  value       = aws_vpc.aish_vpc.id
}
output "subnet_id" {
  description = "ID of subnet"
  value       = aws_subnet.aish_subnet.id
}
output "instance_id" {
  description = "ID of instance"
  value       = aws_instance.aish_instance.id
}
output "instance_public_ip" {
  description = "public ip of instance"
  value       = aws_instance.aish_instance.public_ip
}
output "instance_public_dns" {
  description = "public dns of instance"
  value       = aws_instance.aish_instance.public_dns
}
output "security_group_id" {
  description = "ID of SG"
  value       = aws_security_group.aish_security_group.id
}