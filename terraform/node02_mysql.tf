resource "yandex_compute_instance" "db" {
  name        = "db0${count.index + 1}"
  zone        = "ru-central1-b"
  hostname    = "db0${count.index + 1}"
  count       = 2

  resources {
    cores  = 4
    memory = 4
#    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id    = "fd8autg36kchufhej85b"
      type        = "network-nvme"
      size        = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet.id
    ip_address = "192.168.20.2${count.index + 1}"
    security_group_ids = [
      yandex_vpc_security_group.net-sg-internet.id,
      yandex_vpc_security_group.net-sg-cluster.id
    ]
  }


  scheduling_policy {
    preemptible = true
  }

  metadata = {
    #    user-data = "${file("./user-data")}"
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}