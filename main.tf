terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}

# Создание облачной сети
resource "yandex_vpc_network" "network_1" {
  name = "network-1"
}

# Создание подсети
resource "yandex_vpc_subnet" "subnet_1" {
  name           = "subnet-1"
  zone           = "ru-central1-a"  # Укажите нужную зону доступности
  network_id     = yandex_vpc_network.network_1.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2204-lts" # Ubuntu 22.04 LTS
}

# Создание первой ВМ (slave1)
resource "yandex_compute_instance" "slave1" {
  name        = "slave1"
  zone        = "ru-central1-a"

  resources {
    cores   = 2   # Количество CPU
    memory  = 2   # ОЗУ в ГБ
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
      size     = 10
    }
  }



  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_1.id
    nat       = true
  }

  metadata = {
    user-data = <<-EOF
                #cloud-config
                package_update: true
                packages:
                  - git
                  - curl
                EOF
              
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }      

}

# Создание второй ВМ (slave2)
resource "yandex_compute_instance" "slave2" {
  name        = "slave2"
  zone        = "ru-central1-a"

  resources {
    cores   = 2   # Количество CPU
    memory  = 2   # ОЗУ в ГБ
    
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_1.id
    nat       = true
  }

  metadata = {
    user-data = <<-EOF
                #cloud-config
                package_update: true
                packages:
                  - git
                  - curl
                EOF
              }
}
