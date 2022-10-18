resource "yandex_vpc_security_group" "net-sg-internet" {
  name           = "net-sg-internet"
  network_id     = yandex_vpc_network.net.id

  egress {
    description    = "Allow any outgoing traffic to the Internet"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description       = "Allow any traffic within one security group"
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }
}

resource "yandex_vpc_security_group" "net-sg-cluster" {
  name           = "net-sg-cluster"
  network_id     = yandex_vpc_network.net.id

  ingress {
    description       = "Allow any traffic within one security group"
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }
  ingress {
    description    = "Allow SSH connections to the NAT instance"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
#  ingress {
#    description    = "Allow connections "
#    protocol       = "ANY"
#    port           = 3306
#    v4_cidr_blocks = ["10.10.10.0/0"]
#  }
}

resource "yandex_vpc_security_group" "net-sg-nat-instance" {
  name           = "net-sg-nat-instance"
  network_id     = yandex_vpc_network.net.id

  ingress {
    description    = "Allow any outgoing traffic from the Yandex Data Proc cluster"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description    = "Allow any traffic from the Yandex Data Proc cluster"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow SSH connections to the NAT instance"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "Allow connections from the Data Proc cluster"
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }
#  ingress {
#    description    = "Allow any connections to the DB"
#    protocol       = "ANY"
#    port           = 3306
#    v4_cidr_blocks = ["192.168.20.0/0"]
#  }
}
