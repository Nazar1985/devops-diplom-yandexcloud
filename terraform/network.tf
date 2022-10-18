resource "yandex_vpc_network" "net" {
  name = "net"
}

resource "yandex_vpc_subnet" "public-subnet" {
  name           = "public-subnet"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["10.10.10.0/24"]
  network_id     = yandex_vpc_network.net.id
}

resource "yandex_vpc_subnet" "private-subnet" {
  name           = "private-subnet"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["192.168.20.0/24"]
  network_id     = yandex_vpc_network.net.id
  route_table_id = yandex_vpc_route_table.nat.id
}

/*------------------------------------------------*/

resource "yandex_vpc_route_table" "nat" {
  name = "NAT"
  network_id = yandex_vpc_network.net.id


  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = yandex_compute_instance.nat-instance.network_interface.0.ip_address
  }

  depends_on = [
    yandex_vpc_network.net,
    yandex_compute_instance.nat-instance
  ]
}

/*------------------------------------------------*/
resource "yandex_dns_zone" "dns" {
  name        = "mymind-su"
  zone        = "mymind.su."
  public      = true
  private_networks = [yandex_vpc_network.net.id]
  depends_on = [ yandex_compute_instance.nat-instance ]
}

resource "yandex_dns_recordset" "www" {
  zone_id = yandex_dns_zone.dns.id
  name    = "www"
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.nat-instance.network_interface[0].nat_ip_address]

  depends_on = [yandex_compute_instance.nat-instance, yandex_dns_zone.dns]
}

resource "yandex_dns_recordset" "gitlab" {
  zone_id = yandex_dns_zone.dns.id
  name    = "gitlab"
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.nat-instance.network_interface[0].nat_ip_address]

  depends_on = [yandex_compute_instance.nat-instance, yandex_dns_zone.dns]
}

resource "yandex_dns_recordset" "grafana" {
  zone_id = yandex_dns_zone.dns.id
  name    = "grafana"
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.nat-instance.network_interface[0].nat_ip_address]

  depends_on = [yandex_compute_instance.nat-instance, yandex_dns_zone.dns]
}

resource "yandex_dns_recordset" "prometheus" {
  zone_id = yandex_dns_zone.dns.id
  name    = "prometheus"
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.nat-instance.network_interface[0].nat_ip_address]

  depends_on = [yandex_compute_instance.nat-instance, yandex_dns_zone.dns]
}

resource "yandex_dns_recordset" "alertmanager" {
  zone_id = yandex_dns_zone.dns.id
  name    = "alertmanager"
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.nat-instance.network_interface[0].nat_ip_address]

  depends_on = [yandex_compute_instance.nat-instance, yandex_dns_zone.dns]
}

/*------------------------------------------------*/