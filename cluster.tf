########################################################################
#                                                                      #
#       This is the cluster.tf file with code for the Fargate Cluster  #
#                                                                      #
########################################################################

## Declaring the ECS Cluster
resource "aws_ecs_cluster" "noinc_cluster" {
  name = "noinc-cluster" # Naming the cluster
}

## Declaring the Fargate Service with reference to the cluster, and tasks

resource "aws_ecs_service" "noinc_fargate_service" {
  name            = "noinc-fargate-service"
  cluster         = "${aws_ecs_cluster.noinc_cluster.id}"
  task_definition = "${aws_ecs_task_definition.noinc_fargate_tasks.arn}"
  launch_type     = "FARGATE"
  desired_count   = 3

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
    container_name   = "${aws_ecs_task_definition.noinc_fargate_tasks.family}"
    container_port   = 5000
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true
    security_groups  = ["${aws_security_group.fargate_service_security_group.id}"]
  }
}

## Resource to declare task definition and JSON policy for Containers
resource "aws_ecs_task_definition" "noinc_fargate_tasks" {
  family                   = "noinc-fargate-tasks"
  container_definitions    = <<DEFINITION
   [
    {
      "name": "noinc-fargate-tasks",
      "image": "295548695880.dkr.ecr.us-east-1.amazonaws.com/noincproject:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

