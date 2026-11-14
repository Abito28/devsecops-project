resource "aws_vpc" "devsecops_dev_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.name_prefix}-vpc-main"
  }
}

resource "aws_subnet" "devsecops_dev_subnet_public_a" {
  vpc_id     = aws_vpc.devsecops_dev_vpc.id
  cidr_block = var.public_subnet_cidr

  map_public_ip_on_launch = true

  availability_zone = var.public_subnet_az

  tags = {
    Name = "${var.name_prefix}-subnet-public-a"
  }
}

resource "aws_subnet" "devsecops_dev_subnet_private_a" {
  vpc_id     = aws_vpc.devsecops_dev_vpc.id
  cidr_block = var.private_subnet_cidr

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-subnet-private-a"
  }
}

resource "aws_internet_gateway" "devsecops_dev_igw_main" {
  vpc_id = aws_vpc.devsecops_dev_vpc.id

  tags = {
    Name = "${var.name_prefix}-igw-main"
  }
}

resource "aws_route_table" "devsecops_dev_public_rtb" {
  vpc_id = aws_vpc.devsecops_dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devsecops_dev_igw_main.id
  }

  tags = {
    Name = "${var.name_prefix}-rtb-public"
  }
}

resource "aws_route_table_association" "devsecops_dev_public_rtb_assoc" {
  subnet_id      = aws_subnet.devsecops_dev_subnet_public_a.id
  route_table_id = aws_route_table.devsecops_dev_public_rtb.id
}
#test plan