# Remove any existing ssh keys
rm -fv /etc/ssh/ssh_host_*

# Clear /tmp directories
rm -rf /tmp/*
rm -rf /var/tmp/*

# Clear logs
if [ -f /var/log/vmware-network.log ]; then
    rm -f /var/log/vmware-network.log
fi

if [ -f /var/log/vmware-vmsvc.log ]; then
    rm -f /var/log/vmware-vmsvc.log
fi

truncate -s0 /var/log/wtmp
truncate -s0 /var/log/messages
truncate -s0 /var/log/dmesg
