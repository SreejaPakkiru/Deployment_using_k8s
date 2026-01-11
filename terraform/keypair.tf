# Create a key pair from provided public key material.
# If you prefer to pre-create key pair outside Terraform, set var.public_key = "" and set key_name to that existing key.
# resource "aws_key_pair" "capstone" {
#   key_name  = var.key_name
#   public_key = var.public_key
# }
