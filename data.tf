data "aws_availability_zones" "available" {
  state = "available"
}


data "aws_vpc" "vpc_id" {
  default = true 
}


data "aws_route_table" "routetable" {
  vpc_id = data.aws_vpc.vpc_id.id
  filter {
    name = "association.main"
    values = ["true"]
  }
}