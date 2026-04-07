resource "aws_key_pair" "aish_key_pair" {
  key_name   = "${var.project_name}-${var.environment}-key"
  public_key = file("tf-instance-key.pub")
}
resource "aws_instance" "aish_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = var.sg_id
  key_name      = aws_key_pair.aish_key_pair.key_name
  associate_public_ip_address = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ec2"
  })
  lifecycle {
    create_before_destroy = true
  }
}