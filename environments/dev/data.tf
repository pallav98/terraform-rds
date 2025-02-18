# Fetch existing VPC by name
data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = ["ptt"]
  }
}

# Fetch private subnets in the VPC
data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing_vpc.id]
  }
}

# Fetch existing security group
data "aws_security_group" "existing_sg" {
  filter {
    name   = "tag:Name"
    values = ["ptt-"]
  }
}
