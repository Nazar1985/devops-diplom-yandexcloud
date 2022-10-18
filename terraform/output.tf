#output "v4_cidr_subnet-a" {
#  value = yandex_vpc_subnet.net-subnet-1.v4_cidr_blocks
#}

#output "v4_cidr_subnet-b" {
#  value = yandex_vpc_subnet.net-subnet-2.v4_cidr_blocks
#}

output "internal_ip_address_nginx" {
  value = yandex_compute_instance.nat-instance.network_interface.0.ip_address
}

output "external_ip_address_nginx" {
  value = yandex_compute_instance.nat-instance.network_interface.0.nat_ip_address
}

output "internal_ip_address_db01" {
  value = yandex_compute_instance.db[0].network_interface.0.ip_address
}

output "internal_ip_address_db02" {
  value = yandex_compute_instance.db[1].network_interface.0.ip_address
}

output "internal_ip_address_app" {
  value = yandex_compute_instance.app.network_interface.0.ip_address
}

#output "internal_ip_address_gitlab" {
#  value = yandex_compute_instance.gitlab.network_interface.0.ip_address
#}
#output "internal_ip_address_runner" {
#  value = yandex_compute_instance.runner.network_interface.0.ip_address
#}
#
#output "internal_ip_address_monitor" {
#  value = yandex_compute_instance.monitor.network_interface.0.ip_address
#}

