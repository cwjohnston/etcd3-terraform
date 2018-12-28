resource "aws_elb" "internal" {
  name                      = "${var.role}-internal-${var.environment}"
  security_groups           = ["${aws_security_group.default.id}"]
  cross_zone_load_balancing = true
  subnets                   = ["${aws_subnet.default.*.id}"]
  internal                  = true
  idle_timeout              = 3600

  listener {
    instance_port     = 2379
    instance_protocol = "tcp"
    lb_port           = 2379
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    target              = "HTTP:2379/health"
    interval            = 10
  }

  tags {
    Name        = "etcd ${var.role}.${var.region}.i.${var.environment}.${var.dns["domain_name"]}"
    environment = "${var.environment}"
    role        = "${var.role}"
  }
}

resource "aws_route53_record" "internal" {
  zone_id = "${aws_route53_zone.default.id}"
  name    = "${var.role}-elb.${var.region}.i.${var.environment}.${var.dns["domain_name"]}"
  type    = "A"

  alias {
    name                   = "${aws_elb.internal.dns_name}"
    zone_id                = "${aws_elb.internal.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_elb" "sensu_backend" {
  internal                  = false
  security_groups           = ["${aws_security_group.sensu_lb.id}"]
  cross_zone_load_balancing = true
  subnets                   = ["${aws_subnet.default.*.id}"]
  idle_timeout              = 3600

  listener {
    instance_port     = 3000
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 8081
    instance_protocol = "tcp"
    lb_port           = 8081
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 8080
    instance_protocol = "tcp"
    lb_port           = 8080
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    target              = "HTTP:3000/"
    interval            = 10
  }

  tags {
    Name        = "Sensu Backend ${var.role}.${var.region}.i.${var.environment}.${var.dns["domain_name"]}"
    environment = "${var.environment}"
    role        = "${var.role}"
  }
}