# Creating VPC. VPC CIDR range will be entered by user in runtime.

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  tags = merge(local.project_tags, {Name = "VPCIAC"})
}

# Attaching Internet Gateway to VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.project_tags, {Name = "IGW"})
}

# getting list of available AZs.
data "aws_availability_zones" "AZ" {
  state = "available"
}

# creating public subnets as per user's input. 'availability_zone' creates subnets equally across AZs.
resource "aws_subnet" "public-subnet" {
  count = var.public-subnet-counts
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr,8,count.index)
  availability_zone = data.aws_availability_zones.AZ.names[count.index]
  map_public_ip_on_launch = "true"
  tags = merge(local.project_tags, {Name = "publicsubnet-${count.index +1 }"})
}

# creating private subnets as per user's inputs.
resource "aws_subnet" "private-subnet" {
 count = var.private-subnet-counts
 vpc_id = aws_vpc.vpc.id
 cidr_block = cidrsubnet(var.vpc_cidr,8,count.index+var.public-subnet-counts)
 availability_zone = data.aws_availability_zones.AZ.names[count.index]
 map_public_ip_on_launch = "false"
 tags = merge(local.project_tags, {Name = "privatesubnet-${count.index +1 }"})
}

output "publicsubnetIDs" {
  value = aws_subnet.public-subnet.*.id
}
output "subnetcount" {
  value = length(aws_subnet.public-subnet.*.id)
}
# creating Public Route Table
resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.project_tags, {Name = "PublicRT"})

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# associate public RT with public subnets.
resource "aws_route_table_association" "publicRT-subnet" {
  route_table_id = aws_route_table.PublicRT.id
  count = length(aws_subnet.public-subnet.*.id)
  subnet_id = aws_subnet.public-subnet.*.id[count.index]
}

#creating Private Route Tables as per private subnets' count'. We need a private route table for each private subnet as NAT gateway is configured in HA mode.
/*resource "aws_route_table" "PrivateRT" {
  count = var.private-subnet-counts
 vpc_id = aws_vpc.vpc.id
 tags = merge(local.project_tags, {Name = "PrivateRT-${count.index +1}"})

 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_nat_gateway.nat.*.id[count.index]
 }
}

# associate private route tables with private subnets.
resource "aws_route_table_association" "privateRT-subnet" {
 route_table_id = aws_route_table.PrivateRT.*.id[count.index]
 count = length(aws_subnet.private-subnet.*.id)
 subnet_id = aws_subnet.private-subnet.*.id[count.index]
}
# Allocating EIP for NAT Gateway.
resource "aws_eip" "eip" {
    vpc = "true"
    count = var.private-subnet-counts
  }

# Creating NAT Gateway. Since we configure NAT gateway in each AZ for HA, number of public subnets should be greater
# than or equal to number of private subnets.
resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.eip.*.id[count.index]
    count = length(aws_subnet.private-subnet.*.id)
    subnet_id = aws_subnet.public-subnet.*.id[count.index]
  }
*/
