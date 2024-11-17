variable "name" {
  type    = string
  default = "webapp"
}

variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type = map(string)
  default = {
    "us-east-1a" = "10.0.1.0/24"
    "us-east-1d" = "10.0.2.0/24"
    "us-east-1f" = "10.0.3.0/24"
  }
}

variable "private_subnets" {
  type = map(string)
  default = {
    "us-east-1a" = "10.0.4.0/24"
    "us-east-1d" = "10.0.5.0/24"
    "us-east-1f" = "10.0.6.0/24"
  }
}
