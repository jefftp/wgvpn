# Wireguard VPN VM Template

Packer template for building Alpine Linux as a Wireguard VPN appliance.

- Packages updated as built
- Open-vm-tools installed
- Wireguard installed
- VIM and Nano editors installed
- Template configuration file included /etc/wireguard/wg.conf.tmpl

## Important Security Note

The resulting VM OVA is configured to allow root logins both locally and
remotely through SSH, using passwords. The VM is relying on external
security measures to provide security such as perimeter firewalls,
network microsegmentation, and network-based intrusion prevention.

Use this image at your own peril. If you expose a weakly secured SSH server
to the internet without proper security you're going to get pwned.

## Getting the OVA

If you'd just like to download the OVA, it's available on the releases
page:

<https://github.com/jefftp/wgvpn/releases/tag/v1.1>

## Setup

Once the template is deployed log in to the VM with the VM console and login
as root.

### Change the root password

```bash
passwd
```

### Configure networking

Set a hostname using setup-hostname or edit /etc/resolv.conf.

```bash
> setup-hostname
Enter system hostname (short form, e.g. 'foo') [wgvpn] wgvpn-01
```

The eth0 interface defaults to DHCP, you can use the setup-interfaces
command or edit /etc/network/interfaces to configure a static IP.

```bash
> setup-interfaces
Available interfaces are: eth0
Enter '?' for help on bridges, bonding and vlans.
Which one do you want to initialize? (or '?' or 'done') [eth0] eth0
Ip address for eth0? (or 'dhcp', 'none', '?') [dhcp] 192.168.0.10
Netmask? [255.255.255.0] 255.255.255.0
Gateway? (or 'none') [none] 192.168.0.1
Configuration for eth0:
  type=static
  address=192.168.0.10
  netmask=255.255.255.0
  gateway=192.168.0.1
Do you want to do any manual network configuration? [no] no
```

If using a static IP, configure DNS with the setup-dns command or edit
/etc/resolv.conf.

```bash
> setup-dns
DNS domain name? (e.g. 'bar.com') [] example.com
DNS nameserver(s)? [] 192.168.0.53 192.168.1.53
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
wg genkey | tee wghub.key | wg pubkey > wghub.pub

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
