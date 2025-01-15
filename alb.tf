resource "aws_lb" "main" {
  load_balancer_type = "application"
  tags = {
    Name = "${var.project}-alb"
  }
  security_groups = ["${aws_security_group.allow_http.id}"]
  subnets         = ["${aws_subnet.yk_live_public_1a.id}", "${aws_subnet.yk_live_public_1c.id}"]
}

resource "aws_security_group" "allow_http" {
  name        = "${var.project}-allow-http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.yt_live.id
}

resource "aws_security_group_rule" "allow_http" {
  security_group_id = aws_security_group.allow_http.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound_alb" {
  security_group_id = aws_security_group.allow_http.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # "-1" はすべてのプロトコルを意味します
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lb_target_group" "test_target_group"{
  name = "test-targetgroup"
  target_type = "instance"
  protocol_version = "HTTP1"
  port             = 80
  protocol         = "HTTP"

  vpc_id = aws_vpc.yt_live.id

  health_check {
  interval            = 30
  path                = "/test.html"
  port                = "traffic-port"
  protocol            = "HTTP"
  timeout             = 5
  healthy_threshold   = 5
  unhealthy_threshold = 2
  matcher             = "200,301"
  }
}

resource "aws_lb_target_group_attachment" "test_target_ec2"{
  target_group_arn  = aws_lb_target_group.test_target_group.arn
  target_id = aws_instance.instance.id
}

resource "aws_lb_listener" "test_listener"{
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test_target_group.arn
  }

}