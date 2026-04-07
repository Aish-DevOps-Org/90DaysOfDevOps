resource "aws_vpc" "aish_vpc" {
    cidr_block = "${var.cidr}"
    tags = merge(var.tags, {
        Name = "${var.project_name}-${var.environment}-vpc"
    })
}

resource "aws_subnet" "aish_public_subnet" {
    vpc_id = aws_vpc.aish_vpc.id
    cidr_block = "${var.public_subnet_cidr}"
    map_public_ip_on_launch = true
    availability_zone = var.availability_zone
    tags = merge(var.tags, {
        Name = "${var.project_name}-${var.environment}-public-subnet"
    })
}

resource "aws_internet_gateway" "aish_igw" {
    vpc_id = aws_vpc.aish_vpc.id
    tags = merge(var.tags, {
        Name = "${var.project_name}-${var.environment}-igw"
    })
}

resource "aws_route_table" "aish_public_rt" {
    vpc_id = aws_vpc.aish_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.aish_igw.id
    }
    tags = merge(var.tags, {
        Name = "${var.project_name}-${var.environment}-public-rt"
    })
}

resource "aws_route_table_association" "aish_public_rt_assoc" {
    subnet_id = aws_subnet.aish_public_subnet.id
    route_table_id = aws_route_table.aish_public_rt.id
}