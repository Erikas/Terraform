
# // Single EC2 Instance
# resource "aws_instance" "example" {
#   ami           = "ami-0fb653ca2d3203ac1"
#   instance_type = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.instance.id]

#   user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello, Wolrd" > index.html
#               nohup busybox httpd -f -p ${var.web-server-port} &
#               EOF


#   user_data_replace_on_change = true

#   tags = {
#       Name = "first-example"
#   }
# }

# resource "aws_security_group" "instance" {
#   name = "fist-security-group"

#   ingress {
#     from_port = var.web-server-port
#     to_port = var.web-server-port
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# variable "web-server-port" {
#   default = 8080
#   description = "Web Server port"
#   type = number
# }

# output "public-ip" {
#   description = "EC2 Public IP"
#   value = aws_instance.example.public_ip
# }