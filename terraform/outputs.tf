output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}


output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "instance_ssh_private_key_pem" {
  description = "SSH Private Key PEM"
  value       = tls_private_key.wishlist_ssh_key.private_key_pem
  sensitive   = true
}

output "instance_ssh_public_key" {
  description = "SSH Public Key"
  value       = tls_private_key.wishlist_ssh_key.public_key_openssh
}
