output "vm_public_ip" {
  description = "Elastic IP da instância EC2"
  value       = aws_eip.public_ip.public_ip
}