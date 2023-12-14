locals {
  service_tmp_path      = "/tmp/${var.service_name}.service"
  destination_directory = "/usr/bin/${var.service_name}"
  service_file_content = templatefile("./service.tpl", {
    name    = var.service_name
    command = "${local.destination_directory}/${var.executable_name}"
  })
}

source "azure-arm" "this" {
  client_id                         = var.client_id
  client_secret                     = var.client_secret
  tenant_id                         = var.tenant_id
  subscription_id                   = var.subscription_id
  managed_image_name                = var.image_name
  managed_image_resource_group_name = var.resource_group_name
  os_type                           = "Linux"
  image_publisher                   = "Canonical"
  image_offer                       = "UbuntuServer"
  image_sku                         = "18.04-LTS"
  image_version                     = "latest"
  location                          = "East US"
  vm_size                           = "Standard_DS2_v2"
}

build {
  sources = ["sources.azure-arm.this"]

  provisioner "file" {
    content     = local.service_file_content
    destination = local.service_tmp_path
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir -p ${local.destination_directory}",
      "sudo chown 1000:1000 ${local.destination_directory}",
      "sudo mv ${local.service_tmp_path} /etc/systemd/system/"
    ]
  }

  provisioner "file" {
    source      = var.app_path
    destination = local.destination_directory
  }

  provisioner "shell" {
    inline = [
      "sudo chmod 755 ${local.destination_directory}/*",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable ${var.service_name}.service",
      "sudo systemctl start ${var.service_name}.service"
    ]
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
  }
}
