output "mac1_public_ip" {
  value       = aws_instance.mac1.public_ip
  description = "Public IP of Mac 1 (DNS Server & Client)"
}

output "mac2_public_ip" {
  value       = aws_instance.mac2.public_ip
  description = "Public IP of Mac 2 (Edge/Proxy)"
}

output "mac3_public_ip" {
  value       = aws_instance.mac3.public_ip
  description = "Public IP of Mac 3 (Backend A)"
}

output "mac4_public_ip" {
  value       = aws_instance.mac4.public_ip
  description = "Public IP of Mac 4 (Backend B & Client)"
}

output "mac1_private_ip" {
  value = aws_instance.mac1.private_ip
}

output "mac2_private_ip" {
  value = aws_instance.mac2.private_ip
}

output "mac3_private_ip" {
  value = aws_instance.mac3.private_ip
}

output "mac4_private_ip" {
  value = aws_instance.mac4.private_ip
}
