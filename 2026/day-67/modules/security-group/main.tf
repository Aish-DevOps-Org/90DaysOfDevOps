resource "aws_security_group" "aish_sg" {
    name = "${var.project_name}-${var.environment}-sg"
    description = "Security group for ${var.project_name} in ${var.environment} environment"
    vpc_id = var.vpc_id

    dynamic ingress {
        for_each = var.ingress_ports
        content {
        from_port = ingress.value
        to_port =  ingress.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        }
    }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
    security_group_id = aws_security_group.aish_sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}