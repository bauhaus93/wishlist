variable "instance_name" {
  description = "Value of the name tag for the EC2 instance"
  type        = string
  default     = "Wishlist"
}

variable "ssh_key_name" {
  description = "Value of the name of the SSH key used for accessing the EC instance"
  type        = string
  default     = "aws_wishlist_key"
}
