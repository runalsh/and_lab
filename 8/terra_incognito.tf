/* provider "aws" {
    region = var.aws_region
} */
variable "aws_region" {
    type    = string
    default = "eu-central-1a"
    description = "Default region"
}

variable "key_name" {
    description = "ssh key"
    type = string
    default = "mautorized_key"
}

variable "vpc_cidr" {
    description = "cidr_vpc"
    type = string
    default = "10.0.0.0/18"
}

variable "vpc_name" {
  type        = string
  default     = "instance-"
  description = ""
}

# s3
resource "aws_s3_bucket" "runalshbucket" {
  bucket = "runalshbucket"
  acl    = "private"
  versioning {
    enabled = true
  }
}
resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.runalshbucket.id
  key    = "index.html"
  source = "index.html"

}

resource "aws_s3_bucket_policy" "runalshbucketpol" {
  bucket = aws_s3_bucket.runalshbucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "S3Admin"
    Statement = [
		{
		Sid = "IPAllow",
        Effect = "Allow",
        Principal = "*",
        Action = "s3:PutObject",
        Resource = "arn:aws:s3:::runalshbucket/*"
		}
    ]
  })
}

#ssh key
resource "tls_private_key" "privatekeyssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
  
  provisioner "local-exec" {
    command = "echo '${tls_private_key.privatekeyssh.private_key_pem}' > ~/.ssh/keyssh.pem"
  }
}

resource "aws_key_pair" "privatekeyssh" {
  key_name   = var.key_name
  public_key = tls_private_key.privatekeyssh.public_key_openssh
}


#IAM
resource "aws_iam_role" "s3_role" {
  name = "bucket_s3_read_allow"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = "*"
      },
    ]
  })
}


resource "aws_iam_policy_attachment" "s3_biket_fullaccess" {
  name       = "s3-full"
  roles = [aws_iam_role.s3_role.name] 
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


#secuirity group ec2
resource "aws_security_group" "secuirity_group_ssh_web" {
  name        = "secuirity_group_ssh_web"
  vpc_id      = "aws_vpc.vpc.id"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#VPC hard network fck... :[
# for all universal

resource "aws_vpc" "HARD_VPC" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# gateway to extranet
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.HARD_VPC.id
  tags = {
    Name = "gateway"
  }
}

resource "aws_route" "extranet_availb" {
  route_table_id         = "${aws_vpc.HARD_VPC.main_route_table_id}"
  gateway_id             = "${aws_internet_gateway.gateway.id}"
  destination_cidr_block = "0.0.0.0/0"
}

# istance per aviablity zone
resource "aws_subnet" "subnet1" {
  vpc_id                  = "${aws_vpc.HARD_VPC.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = "${aws_vpc.HARD_VPC.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[1]
}

# instances

data "aws_ami" "amazon_ami" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_iam_instance_profile" "instance_profile_role_for_ec2" {
  name = "iam_instance_profile"
  role = aws_iam_role.s3_role.name
}

# load balancer
/* resource "aws_lb" "load balancer" {
  name = "runalshlb"
  load_balancer_type = "application"
  subnets         = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  security_groups = [aws_security_group.secuirity_group_ssh_web.id]
  enable_deletion_protection = true
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load balancer.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_target_group" "http" {
  name_prefix = "task-"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
} */

resource "aws_elb" "load_balancer" {
  name_prefix        = "lb"  
#no more 6 symb
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  cross_zone_load_balancing   = true

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 4
    timeout = 5
    interval = 60
    target = "HTTP:80/"
# 	"health_check.0.target" must contain a path in the Health Check target: HTTP:80
  }

  listener {
	  instance_port = "80"
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
}

#health check

/* resource "aws_cloudwatch_metric_alarm" "heath_check" {
  alarm_name                = "terraform-test-foobar5"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
}
 */
 # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm
resource "aws_cloudwatch_metric_alarm" "cloudwatch_heath_check" {
  alarm_name          = "cloudwatch_to_web_servers"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "hostisactive"
  namespace           = "AWS/ApplicationELB"
# namespace           = "AWS/ApplicationLB"
  period              = "120"
  statistic           = "Average"
  threshold           =  80
  alarm_description   = "This metric monitors web services"
  actions_enabled     = "true"
  ok_actions          = [aws_sns_topic.dontworkingAAAAAAA.arn]
  alarm_actions       = [aws_sns_topic.dontworkingAAAAAAA.arn]
  dimensions = {
    LoadBalancer = aws_elb.load_balancer.name
  }
}

resource "aws_sns_topic" "dontworkingAAAAAAA" {
  name = "dontworkingAAAAAAA"
}

# HERE CAN BE AUTO RECOVERY BUT SOME HARD - 
# how make autorecovery - may be throw autoscaling ??? :I
# some like sns  - >  aws_autoscaling_group  ¯\_(ツ)_/¯



# RUN , FOREST, RUN
resource "aws_launch_configuration" "nginx" {
  name_prefix     = "server"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.instance_profile_role_for_ec2.id
  security_groups = [aws_security_group.secuirity_group_ssh_web.id]

  key_name  = aws_key_pair.privatekeyssh.key_name
  user_data = file("provision.sh")
  
  lifecycle {
    create_before_destroy = true
  }
}




















