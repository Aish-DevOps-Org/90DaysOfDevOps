output "vpc_id" {
  description = "ID of VPC"
  value       = aws_default_vpc.aish_vpc.id
}
output "subnet_id" {
  description = "ID of subnet"
  value       = aws_default_subnet.aish_default_subnet.id
}
output "all_instance_ids" {
  description = "ID of instance"
  value       = aws_instance.aish_instance[*].id
}

output "instance_public_ip" {
  description = "public ip of instance"
  value       = aws_instance.aish_instance[*].public_ip
}
output "instance_public_dns" {
  description = "public dns of instance"
  value       = aws_instance.aish_instance[*].public_dns
}
output "security_group_id" {
  description = "ID of SG"
  value       = aws_security_group.aish_security_group.id
}

output "instance_name" {
  description = "name of instance"
  value       = aws_instance.aish_instance[*].tags["Name"]
}