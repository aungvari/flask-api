# sources used
# https://github.com/anrim/terraform-aws-ecs
# https://aws.amazon.com/getting-started/hands-on/deploy-docker-containers/
# https://github.com/arminc/terraform-ecs
# https://www.terraform.io/docs/providers/aws
# https://github.com/terraform-aws-modules/terraform-aws-ecs
# http://blog.shippable.com/create-a-container-cluster-using-terraform-with-aws-part-1
# https://www.chakray.com/creating-fargate-ecs-task-aws-using-terraform/
# https://registry.terraform.io/modules/cn-terraform/ecs-fargate-service/aws/2.0.4


#provider.tf
provider "aws" {
  region = "eu-central-1"
}


########################### START NETWORK CONFIG ###########################

resource "aws_vpc" "main" { 
  cidr_block = "10.0.0.0/16" 
  enable_dns_hostnames = true
}

resource "aws_route_table" "external" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
}

resource "aws_route_table_association" "external-main" {
    subnet_id = aws_subnet.main.id
    route_table_id = aws_route_table.external.id
}

resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "eu-central-1a"
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "ecs" {
    name = "ecs"
    description = "Allow tcp traffic on port 80"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

########################### END NETWORK CONFIG ###########################



########################### START IAM CONFIG ###########################

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "flask-execution-role"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
resource "aws_iam_role" "ecs_task_role" {
  name = "flask-role"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

########################### END IAM CONFIG ###########################


resource "aws_ecs_cluster" "cluster" {
  name = "flask-api"
}

resource "aws_ecs_service" "service" {
  name = "ecs-service"
  cluster = aws_ecs_cluster.cluster.arn
  desired_count = 1
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.definition.arn
  network_configuration {
    subnets = [ "${aws_subnet.main.id}" ]
    security_groups = ["${aws_security_group.ecs.id}" ]
    assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "definition" {
  family                   = "flask_app"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]

container_definitions = <<DEFINITION
[
  {
    "image": "714172735080.dkr.ecr.eu-central-1.amazonaws.com/aungvari/chemaxon:latest",
    "name": "flask-container",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      } ]
  }
  
]
DEFINITION
}
