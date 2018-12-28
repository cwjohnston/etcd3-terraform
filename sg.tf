resource "aws_security_group" "default" {
  name        = "${var.role}.${var.region}.i.${var.environment}.${var.dns["domain_name"]}"
  description = "ASG-${var.role}"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    Name        = "${var.role}.${var.region}.i.${var.environment}.${var.dns["domain_name"]}"
    role        = "${var.role}"
    environment = "${var.environment}"
  }

  # etcd peer + client traffic within the etcd nodes themselves
  ingress {
    from_port = 2379
    to_port   = 2380
    protocol  = "tcp"
    self      = true
  }

  # etcd client traffic from ELB
  egress {
    from_port = 2379
    to_port   = 2380
    protocol  = "tcp"
    self      = true
  }

  # etcd client traffic from the VPC
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.default.cidr_block}"]
  }

  egress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.default.cidr_block}"]
  }
}

resource "aws_security_group" "sensu_lb" {
  name        = "${var.role}.${var.region}.i.${var.environment}.${var.dns["domain_name"]} sensu-go load balancer"
  description = "ELB-SensuBackend"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8081
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.default.cidr_block}"]
  }
  egress {
    from_port   = 8080
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.default.cidr_block}"]
  }
}

resource "aws_security_group" "sensu_backend" {
  name        = "${var.role}.${var.region}.i.${var.environment}.${var.dns["domain_name"]} sensu-go backend"
  description = "ASG-SensuBackend"
  vpc_id      = "${aws_vpc.default.id}"

// SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "SSH Access"
  }
// backend dashboard listener port
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "backend dashboard listener port"
  }
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "TCP"
    security_groups = ["${aws_security_group.sensu_lb.id}"]
  }
// agent socket
  ingress {
    from_port   = 3030
    to_port     = 3030
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "agent socket"
  }
  ingress {
    from_port   = 3030
    to_port     = 3030
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "agent socket"
  }
// agent http api
  ingress {
    from_port   = 3031
    to_port     = 3031
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "agent socket"
  }
// pprof debug
  ingress {
    from_port   = 6060
    to_port     = 6060
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "pprof debug"
  }
// backend http api listener
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "backend http api listener"
  }
// agent listener port
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "agent listener port"
  }
// agent statsd port
  ingress {
    from_port   = 8125
    to_port     = 8125
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "agent statsd port"
  }
  ingress {
    from_port   = 8125
    to_port     = 8125
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "agent statsd port"
  }
// extension port
  ingress {
    from_port   = 31000
    to_port     = 31000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "extension port"
  }
// etcd ports
  ingress {
    from_port   = 2379
    to_port     = 2379
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "backend listen client port"
  }
  ingress {
    from_port   = 2380
    to_port     = 2380
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "backend listen peer port"
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}