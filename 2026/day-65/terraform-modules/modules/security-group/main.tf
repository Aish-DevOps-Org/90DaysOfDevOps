resource "aws_security_group" "aish_security_group" {
    name = var.sg_name
    tags = var.tags
    vpc_id = var.vpc_id
    dynamic "ingress" {
        for_each = var.ingress_ports
        content {
            from_port = ingress.value
            to_port = ingress.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
    security_group_id = aws_security_group.aish_security_group.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}
