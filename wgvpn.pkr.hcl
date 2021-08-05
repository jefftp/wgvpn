
variable "root_password" {
  type = string
  default = ""
  sensitive = true
}

source "vmware-iso" "wgvpn" {
  iso_url              = "https://dl-cdn.alpinelinux.org/alpine/v3.14/releases/x86_64/alpine-virt-3.14.1-x86_64.iso"
  iso_checksum         = "sha256:b9269006e9532c6916895a6427719db68751a0c8e4cd10a2cdb62a34e870ff00"
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
    "setup-alpine -f answers<enter><wait10>",
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
