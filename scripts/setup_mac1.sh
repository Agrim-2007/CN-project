#!/bin/bash
apt-get update
apt-get install -y dnsmasq dnsutils tcpdump tshark curl

# Stop systemd-resolved from listening on port 53 (if it does) or just bind dnsmasq
# Systemd-resolved listens on 127.0.0.53:53. Dnsmasq will fail to bind if it binds to 0.0.0.0:53.
# We will explicitly bind dnsmasq to the ethernet IP: 10.0.1.10

cat <<EOF > /etc/dnsmasq.conf
listen-address=10.0.1.10
bind-interfaces
address=/app.team1.test/10.0.1.20
address=/api.team1.test/10.0.1.20
EOF

systemctl restart dnsmasq
systemctl enable dnsmasq

# Also configure systemd-resolved to use 10.0.1.10 as DNS
sed -i 's/#DNS=/DNS=10.0.1.10/' /etc/systemd/resolved.conf
systemctl restart systemd-resolved
