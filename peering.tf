resource "aws_vpc_peering_connection" "roboshop-default" {
    count = var.is_peering_require ? 1 : 0
 
  peer_vpc_id   = data.aws_vpc.vpc_id.id # acceptor
  vpc_id        = aws_vpc.main.id

   accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
  auto_accept = true

  tags = merge(
    var.vpc_tags,
    local.common_tags,
    
    {
        Name = local.commonname-suffix
    }
  )
}


resource "aws_route" "public_peering" {
     count = var.is_peering_require ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.vpc_id.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.roboshop-default[count.index].id
}

resource "aws_route" "default_peering" {
     count = var.is_peering_require ? 1 : 0
  route_table_id            = data.aws_route_table.routetable.id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.roboshop-default[count.index].id
}