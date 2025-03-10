
provider "aws" {
  region = "us-east-2"
}

// Data
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
//

// EC2 Launch Template With Scaling Group
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
  target_group_arns = [aws_lb_target_group.asg.arn]

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
    security_groups = [aws_security_group.asg-lb.id]
  }
}
///

// loud balancer
    resource "aws_lb" "asg" {
      name = "asg-lb"
      load_balancer_type = "application"
      subnets = data.aws_subnets.default.ids
      security_groups = [aws_security_group.asg-lb.id]
    }
    
    resource "aws_security_group" "asg-lb" {
      name = "asg-lb-security-group"

      # Inbound Http Request
      ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      # outbound to internal infra
      egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
      }    
    }


    // loud balancer - listener
      resource "aws_lb_listener" "asg-lb" {
        load_balancer_arn = aws_lb.asg.arn
        port = 80
        protocol = "HTTP"

        default_action {
          type = "fixed-response"

          fixed_response {
            content_type = "text/plain"
            message_body = "404: page not found"
            status_code = 404
          }
        }
      }
    //
    // loud balancer - listener rules
    resource "aws_lb_listener_rule" "asg-lb" {
      listener_arn = aws_lb_listener.asg-lb.arn
      priority = 100

      condition {
        path_pattern {
          values = ["/*"]
        }
      }

      action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
      }
    }

    //


    // loud balancer - target group
    resource "aws_lb_target_group" "asg" {
      name = "alb-target-group"
      port = var.web-server-port
      protocol = "HTTP"
      vpc_id = data.aws_vpc.default.id

      health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
      }
    }
    //
//

// variables
variable "web-server-port" {
  default = 8080
  description = "Web Server port"
  type = number
}
//


// output
output "lb-public-ip" {
 value = aws_lb.asg.dns_name
 description = "entry point"
}

//