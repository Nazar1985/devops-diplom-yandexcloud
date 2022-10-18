# delete locals
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  cloud {
    organization = "nzastavnuy"
    workspaces {
      name = "stage"
    }
  }
}

provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = var.YC_CLOUD_ID
  folder_id = var.YC_FOLDER_ID
}
