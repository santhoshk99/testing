variable "vpc_cidr" {
  description = "Enter VPC CIDR"
}

variable "region" {
  description = "Enter Region"
  type = string
}

/*variable "subnet-counts" {
  description = "Enter Public Subnet Count"
  type = number
}
*/
variable "private-subnet-counts" {
  description = "Enter Private Subnet Count"
  type = number
}

variable "public-subnet-counts" {
  description = "Enter Public Subnet Count"
  type = number
}
locals {
  project_tags = {
    createdby = "terraform"
    project = "1"

  }
}

variable "sgports" {
  type = list(number)
  description = "Enter ports to be allowed in Security Group"
}
