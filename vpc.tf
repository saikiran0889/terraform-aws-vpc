
# VPC(Virtual private cloud)
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
    enable_dns_hostnames = true
  tags = merge(
    var.vpc_tags,
    local.common_tags,
    
    {
        Name = local.commonname-suffix
    }
  )
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id # Reference the ID of the VPC created above

  tags = merge(
    var.igw_tags,
    local.common_tags,
    
    {
        Name = local.commonname-suffix
    }
  )
}

# Public subnet
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone = local.az_names[count.index]
 
  tags = merge(
    var.public_subnet_tags,
    local.common_tags,
    
    {
        Name = "${local.commonname-suffix}-public-${local.az_names[count.index]}" # roboshop-dev-public-us-east-1a
    }
  )
}

# Private subnet
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[count.index]

  availability_zone = local.az_names[count.index]
 
  tags = merge(
    var.private_subnet_tags,
    local.common_tags,
    
    {
        Name = "${local.commonname-suffix}-private-${local.az_names[count.index]}" # roboshop-dev-private-us-east-1a
    }
  )
}

# database subnet
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidr[count.index]

  availability_zone = local.az_names[count.index]
 
  tags = merge(
    var.database_subnet_tags,
    local.common_tags,
    
    {
        Name = "${local.commonname-suffix}-database-${local.az_names[count.index]}" # roboshop-dev-database-us-east-1a
    }
  )
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.public_routetable_tags,
    local.common_tags,
    
    {
        Name = "${local.commonname-suffix}-public"
    }
  )
}

# Private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.private_routetable_tags,
    local.common_tags,
    
    {
        Name = "${local.commonname-suffix}-private"
    }
  )
}

# database route table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.database_routetable_tags,
    local.common_tags,
    
    {
        Name = "${local.commonname-suffix}-database"
    }
  )
}

# Public route
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

# elastic ip
resource "aws_eip" "nat" {
    domain   = "vpc"
 tags = merge(
    var.eip_tags,
    local.common_tags,
    
    {
        Name = "${local.commonname-suffix}-nat"
    }
  )

}


# nat gateway
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.nat_tags,
    local.common_tags,
    
    {
        Name = "${local.commonname-suffix}"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# private egree route through nat
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.natgw.id
}

# batabase egress route through nat
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.natgw.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
  
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
  
}


resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidr)
  subnet_id = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
  
}