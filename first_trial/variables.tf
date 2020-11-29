provider "aws" {
  region  = "us-east-2"
}

variable "name" {
  type = string
  description = "The name you want to give your RDS database."
  default = "mydb"
}

variable "vpc_id" {
  type = string
  description = "The ID of the VPS you want to create the security group in"
  default = "vpc-86df03ed"
}

variable "product_tag" {
  type = string
  description = "Value of the Product key tag in order to tag resources win which product they belong to"
  default = "rds"
}

variable "security_groups" {
  type = map
  description = "Map of security group ids and the descriptions that will be used to allow inbound access to the RDS. The key needs to be a security group id and the value is the description"

  default = {
    sg-f43f1a8c = "sg-f43f1a8c"
  }
}

variable "max_capacity" {
  type = number
  description = "Maximum capcity to scale up to in regards to processing and memory cacpacity. Accepted values are 1,2,4,8,16,32,64,128,256. Default is 16"
  default = 16
}

variable "min_capacity" {
  type = number
  description = "Minimum capcity to scale down to in regards to processing and memory cacpacity. Accepted values are 1,2,4,8,16,32,64,128,256. Default is 2"
  default = 2
}

variable "database_username" {
  type=string
  description = "Username you want to give the RDS cluster in order to set up access"
  default = "admin"
}

variable "database_password" {
  type = string
  description = "Password you want to set as the access for the associated username"
  default = "adminadmin"
}

variable "auto_pause" {
  type=number
  description = "The number of seconds before RDS Serverless is paused. Default is 300"
  default = 300

}