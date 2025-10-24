locals {
  common_tags = {
    Project = var.projectname
    Environment = var.environment
    Terraform = true
  }
  commonname-suffix = "${var.projectname}-${var.environment}" # robosop-dev

  az_names = slice(data.aws_availability_zones.available.names, 0, 2)

}