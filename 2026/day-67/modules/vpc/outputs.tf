output "vpc_id" {
  value = aws_vpc.aish_vpc.id
}

output "subnet_id" {
  value = aws_subnet.aish_public_subnet.id
}