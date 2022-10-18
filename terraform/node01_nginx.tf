resource "yandex_compute_instance" "nat-instance" {
  name        = "nat-instance"
  zone        = "ru-central1-a"
  hostname = "proxy"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id    = "fd8v7ru46kt3s4o5f0uo"
      type        = "network-nvme"
      size        = 40
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public-subnet.id
    ip_address = "10.10.10.10"
    security_group_ids = [
      yandex_vpc_security_group.net-sg-internet.id,
      yandex_vpc_security_group.net-sg-nat-instance.id
    ]
    nat        = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    #    user-data = "${file("./user-data")}"
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}