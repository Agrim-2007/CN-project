#!/bin/bash
apt-get update
apt-get install -y nginx openssl tcpdump tshark curl dnsutils

# Configure DNS to use Mac 1
mkdir -p /etc/systemd/resolved.conf.d/
cat <<EOF > /etc/systemd/resolved.conf.d/cn-project.conf
[Resolve]
DNS=10.0.1.10
Domains=~test
EOF
systemctl restart systemd-resolved

# Generate Self-Signed Cert
mkdir -p /etc/ssl/private /etc/ssl/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out /etc/ssl/certs/nginx-selfsigned.crt \
  -subj "/C=US/ST=State/L=City/O=Team1/CN=app.team1.test"

# Nginx config
cat <<'EOF' > /etc/nginx/sites-available/default
upstream backends {
    server 10.0.1.30:3001;
    server 10.0.1.40:3002;
}

server {
    listen 80 default_server;
    server_name app.team1.test api.team1.test;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl default_server;
    server_name app.team1.test api.team1.test;

    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

    location / {
        proxy_pass http://backends;
        proxy_set_header Host $host;
        add_header Cache-Control "max-age=60";
    }
}
EOF

systemctl restart nginx
systemctl enable nginx
