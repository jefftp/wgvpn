# Wireguard VPN VM Template

Packer template for building Alpine Linux as a Wireguard VPN appliance.

- Packages updated as built
- Open-vm-tools installed
- Wireguard installed
- VIM and Nano editors installed
- Template configuration file included /etc/wireguard/wg.conf.tmpl

## Important Security Note

The resulting VM OVA is configured to allow root logins both locally and remotely through SSH, using passwords. The VM is relying on external security measures to provide security such as perimeter firewalls, network microsegmentation, and network-based intrusion prevention.

Use this image at your own peril. If you expose a weakly secured SSH server to the internet without proper security you're going to get pwned.

## Setup

Once the template is deployed log in to the VM with the VM console and login as root.

### Change the root password

```bash
passwd
```

### Configure networking

```bash
# Set the system hostname
echo "iland-vpn-01" > /etc/hostname
hostname -F /etc/hostname

# Configure a nameserver (using Cloudflare)
echo "nameserver 1.1.1.1" > /etc/resolv.conf
```

Using either vim or nano, edit /etc/network/interfaces:

```readline config
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
  address 172.18.0.254
  netmask 255.255.255.0
  gateway 172.18.0.1
```

Restart networking to put changes into effect.

```bash
service networking restart
```

### Configure wireguard

```bash
cd /etc/wireguard

# Create all new files with no read, write, or execute permissions for
# groups or others.
umask 077

# Generate the private key.
# Save the private key to wghub.key.
# Use the private key to generate the public key.
# Save the public key to wghub.pub.
sudo wg genkey | tee wghub.key | wg pubkey > wghub.pub

# Create a wireguard config
cp wg.conf.tmpl wg0.conf
```

Using either vim or nano, edit wg0.conf.

```readline config
[Interface]
Address = #vpn_local_tun_ip
PrivateKey = #vpn_local_private_key
ListenPort = #vpn_port

[Peer]
Endpoint = #vpn_peer_ip
PublicKey = #vpn_peer_public_key
AllowedIPs = #vpn_allowed_ips
PersistentKeepalive = 25
```

### Configure wireguard to start automatically

```bash
ln -s /etc/init.d/wireguard /etc/init.d/wireguard.wg0

rc-update add wireguard.wg0 default

service wireguard.wg0 start
```
