
variable "root_password" {
  type = string
  default = ""
  sensitive = true
}

source "vmware-iso" "wgvpn" {
  iso_url              = "https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/x86_64/alpine-virt-3.15.0-x86_64.iso"
  iso_checksum         = "sha256:e97eaedb3bff39a081d1d7e67629d5c0e8fb39677d6a9dd1eaf2752e39061e02"
  vm_name              = "wgvpn"
  version              = "13"
  guest_os_type        = "other3xlinux-64"
  cores                = 1
  cpus                 = 1
  memory               = 512
  disk_size            = 1024
  boot_wait            = "15s"
  http_directory       = "http"
  shutdown_command     = "/sbin/poweroff"
  ssh_timeout          = "30m"
  ssh_username         = "root"
  ssh_password         = "${var.root_password}"
  network_adapter_type = "VMXNET3"
  vmx_data = {
    "disk.EnableUUID"  = "TRUE"
    "scsi0.virtualdev" = "pvscsi"
  }
  boot_command         = [
    "root<enter><wait>",
    "ifconfig eth0 up<enter>",
    "udhcpc -i eth0<enter><wait10>",
    "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/answers<enter><wait>",
    "USERANSERFILE=1 setup-alpine -f answers<enter><wait10>",
    "${var.root_password}<enter><wait>",
    "${var.root_password}<enter>",
    "<wait20s>y<enter><wait30s>",
    "reboot<enter><wait30s>",
    "root<enter><wait>",
    "${var.root_password}<enter><wait>",
    "sed -i 's/^#PermitRootLogin .*/PermitRootLogin yes/g' /etc/ssh/sshd_config<enter>",
    "service sshd restart<enter>",
    "exit<enter>"
  ]
}

build {
  sources = ["source.vmware-iso.wgvpn"]

  provisioner "file" {
    sources     = [
      "files/wireguard.openrc",
      "files/wg.conf.tmpl",
      "files/motd"
    ]
    destination = "/tmp/"
  }
  provisioner "shell" {
    scripts = [
      "files/setup.sh",
      "files/cleanup.sh"
    ]
  }
  post-processor "shell-local" {
    inline = ["ovftool output-wgvpn/wgvpn.vmx wgvpn-`date +%Y%m%d`.ova", "rm -rf output-wgvpn"]
  }
}
