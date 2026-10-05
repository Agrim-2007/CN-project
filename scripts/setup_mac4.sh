#!/bin/bash
apt-get update
apt-get install -y python3 python3-flask python3-pip tcpdump tshark curl dnsutils

# Configure DNS to use Mac 1
mkdir -p /etc/systemd/resolved.conf.d/
cat <<EOF > /etc/systemd/resolved.conf.d/cn-project.conf
[Resolve]
DNS=10.0.1.10
Domains=~test
EOF
systemctl restart systemd-resolved

mkdir -p /opt/backend
cat <<'EOF' > /opt/backend/app.py
from flask import Flask, jsonify, make_response
app = Flask(__name__)

@app.route('/')
def index():
    resp = make_response(jsonify({"message": "Service is running on Backend B"}))
    resp.headers['X-Backend'] = 'B'
    return resp

@app.route('/api/status')
def status():
    resp = make_response(jsonify({"backend": "B", "status": "ok"}))
    resp.headers['X-Backend'] = 'B'
    return resp

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3002)
EOF

# Create systemd service
cat <<'EOF' > /etc/systemd/system/backend.service
[Unit]
Description=Backend B Service
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/backend/app.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start backend
systemctl enable backend
