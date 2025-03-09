provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource  "aws_launch_template" "example" {
  image_id = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  
  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello, Wolrd" > index.html
              nohup busybox httpd -f -p ${var.web-server-port} &
              EOF
  )

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "default" {
  launch_template {
    id = aws_launch_template.example.id
  }

  vpc_zone_identifier = data.aws_subnets.default.ids

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true    
  }
  
}

resource "aws_security_group" "instance" {
  name = "fist-security-group"

  ingress {
    from_port = var.web-server-port
    to_port = var.web-server-port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "web-server-port" {
  default = 8080
  description = "Web Server port"
  type = number
}
