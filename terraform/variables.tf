variable "region" {
  default = "eu-west-1"
}

# variable "region_number" {
#   # Arbitrary mapping of region name to number to use in
#   # a VPC's CIDR prefix.
#   default = {
#     us-east-1      = 1
#     us-west-1      = 2
#     us-west-2      = 3
#     eu-central-1   = 4
#     ap-northeast-1 = 5
#   }
# }

# variable "az_number" {
#   # Assign a number to each AZ letter used in our configuration
#   default = {
#     a = 1
#     b = 2
#     c = 3
#     d = 4
#     e = 5
#     f = 6
#   }
# }

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  default     = "10.9.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "Public Subnet CIDR block"
  default     = "10.9.0.0/24"
}

variable "private_subnet_cidr_block" {
  description = "Private Subnet CIDR block"
  default     = "10.9.1.0/24"
}

variable "profile" {
  default = "default"
}

variable "shared_credentials_file" {
  default = "~/.aws/credentials"
}
