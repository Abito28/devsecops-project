output "vpc_id" {
  value = aws_vpc.devsecops_dev_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.devsecops_dev_subnet_public_a.id
}

output "private_subnet_id" {
  value = aws_subnet.devsecops_dev_subnet_private_a.id
}