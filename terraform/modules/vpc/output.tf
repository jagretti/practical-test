output "id" {
  value = aws_vpc.this.id
}

output "cidr" {
  value = aws_vpc.this.cidr_block
}

output "public_subnets" {
  value = aws_vpc.this.aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_vpc.this.aws_subnet.private[*].id
}
