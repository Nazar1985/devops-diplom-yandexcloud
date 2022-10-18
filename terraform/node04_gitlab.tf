resource "yandex_compute_instance" "gitlab" {
  name        = "gitlab"
  zone        = "ru-central1-b"
  hostname = "gitlab"

  resources {
    cores  = 4
    memory = 4
  }


  boot_disk {
    initialize_params {
      image_id    = "fd8autg36kchufhej85b"                   #  fd89dsd1oshk57psq3h9   gitlabCI 15.3
      size        = 40
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.private-subnet.id
    ip_address = "192.168.20.40"
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