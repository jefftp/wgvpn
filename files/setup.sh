# Disable unnecessary serial console
sed -i 's/^\(ttyS0.*\)/#\1/g' /etc/inittab

# Disable tty5 and tty6
sed -i 's/^\(tty5.*\)/#\1/g' /etc/inittab
sed -i 's/^\(tty6.*\)/#\1/g' /etc/inittab

# Add community repository
echo "http://dl-cdn.alpinelinux.org/alpine/v3.11/community" >> /etc/apk/repositories

# Update and Upgrade
apk update
apk upgrade

# Install packages
apk add open-vm-tools wireguard-tools vim nano

# Start services
rc-update add open-vm-tools default

# Enable IPv4 IP Forwarding
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/10-ipv4-ip-forward.conf

# Copy wireguard configuration template into place
cp /tmp/wg.conf.tmpl /etc/wireguard
chmod 600 /etc/wireguard/wg.conf.tmpl

# Copy motd into place
cp /tmp/motd /etc/motd
chmod 644 /etc/motd
