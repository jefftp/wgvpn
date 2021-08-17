#!/bin/sh

# Disable unnecessary serial console
sed -i 's/^\(ttyS0.*\)/#\1/g' /etc/inittab

# Disable tty5 and tty6
sed -i 's/^\(tty5.*\)/#\1/g' /etc/inittab
sed -i 's/^\(tty6.*\)/#\1/g' /etc/inittab

# Add community repository
echo "http://dl-cdn.alpinelinux.org/alpine/v3.14/community" >> /etc/apk/repositories

# Update and Upgrade
apk update
apk upgrade

# Install packages
apk add open-vm-tools mandoc man-pages wireguard-tools wireguard-tools-doc vim vim-doc nano nano-doc

# Start services
rc-update add open-vm-tools boot

# Enable IPv4 IP Forwarding
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/10-ipv4-ip-forward.conf

# Copy wireguard openrc script into place
cp /tmp/wireguard.openrc /etc/init.d/wireguard
chmod 755 /etc/init.d/wireguard

# Copy wireguard configuration template into place
cp /tmp/wg.conf.tmpl /etc/wireguard
chmod 600 /etc/wireguard/wg.conf.tmpl

# Copy motd into place
cp /tmp/motd /etc/motd
chmod 644 /etc/motd
