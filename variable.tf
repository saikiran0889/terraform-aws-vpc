variable "vpc_cidr" {
    type = string
  default = "10.0.0.0/16"
}

variable "projectname" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_tags" {
    type = map
    default = {}
  
}

variable "igw_tags" {
  default = {}
  
}
variable "public_subnet_tags" {
  default = {}
}
variable "public_subnet_cidr" {
  type = list
}

variable "private_subnet_tags" {
  default = {}
}
variable "private_subnet_cidr" {
  type = list
}
variable "database_subnet_tags" {
  default = {}
}
variable "database_subnet_cidr" {
  type = list
}

variable "public_routetable_tags" {
  default = {}
  
}

variable "private_routetable_tags" {
  default = {}
  
}

variable "database_routetable_tags" {
  default = {}
  
}

variable "eip_tags" {
  default = {}
  
}

variable "nat_tags" {
  default = {}
  
}


variable "is_peering_require" {
  type = bool
  default = true
}