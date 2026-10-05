# Computer Networks Course Project - Phase 1

This repository contains the infrastructure as code (Terraform) and backend applications required for **Phase 1: Build & Observe** of the Private Network Service Platform project.

Because we are deploying this in the cloud instead of using 4 physical laptops, we use **AWS EC2** to spin up 4 Ubuntu VMs simulating the 4 Macs described in the project. These instances run within a single isolated AWS Virtual Private Cloud (VPC), serving as the "Private LAN".

## Architecture Mapping

| Project Role | Cloud VM Name | Private IP | Software / Purpose |
|--------------|---------------|------------|--------------------|
| **Mac 1** | `Mac1-DNS-Client` | `10.0.1.10` | `dnsmasq` (DNS Server) & Test Client |
| **Mac 2** | `Mac2-Edge-Proxy` | `10.0.1.20` | `nginx` (Load Balancer, TLS termination) |
| **Mac 3** | `Mac3-Backend-A` | `10.0.1.30` | Python Flask API A (Port 3001) |
| **Mac 4** | `Mac4-Backend-B-Client` | `10.0.1.40` | Python Flask API B (Port 3002) & Test Client |

## 1. Deployment (Terraform)

1. Connect to your AWS Account (you can use AWS CloudShell, or local terminal with AWS CLI configured).
2. Clone this repository in your AWS environment.
3. Navigate to the `terraform/` directory:
   ```bash
   cd terraform
   ```
4. Initialize and apply the Terraform configuration:
   ```bash
   terraform init
   terraform apply -auto-approve
   ```
5. Note the output IP addresses. You will use these Public IPs to SSH into each instance.
   *(Note: For the project demonstrations, use the Private IPs (`10.0.1.x`) and hostnames, just as you would on a local network!)*

## 2. Demonstration Guide (Phase 1 Checklist)

Wait a few minutes after `terraform apply` for the `user_data` scripts to finish installing everything on all 4 instances.
Then, you can SSH into **Mac 1** or **Mac 4** (which act as your "Test Clients") to perform your demonstrations.

To SSH into Mac 1 (using its Public IP):
```bash
ssh ubuntu@<MAC1_PUBLIC_IP>
```

### Task A: Private LAN
Run `ping` between the machines using their private IPs.
```bash
ping 10.0.1.20
ping 10.0.1.30
ping 10.0.1.40
```

### Task B: Private DNS Server
Run `dig` or `nslookup` on the DNS name. Our client machines are preconfigured (via systemd-resolved) to use Mac 1 (`10.0.1.10`) as their DNS resolver.
```bash
dig app.team1.test
```
You should see it resolves to `10.0.1.20` (Mac 2's IP).

### Task C & D & E: HTTP/HTTPS & Load Balancing
Hit the endpoints repeatedly to show the round-robin load balancing.
```bash
curl -k -v https://app.team1.test/api/status
```
*Note: We use `-k` (insecure) here because we are using a self-signed cert on the command line. For a perfect demo as required ("no -k flag in curl"), you can add the self-signed CA to Ubuntu's trusted store.*

To see the `X-Backend` headers alternating between A and B:
```bash
curl -k -I https://app.team1.test/
```

### Task F: Caching Behavior
Show the Cache-Control header:
```bash
curl -k -I https://app.team1.test/
```
You will see `Cache-Control: max-age=60`.

### Task G: Wireshark / tcpdump Evidence
To capture the DNS, TCP handshake, and TLS handshake:
Run `tcpdump` on Mac 1 or Mac 4, save it to a file, and then download it to view in Wireshark locally.
```bash
# Start capture in the background (capturing all traffic on eth0)
sudo tcpdump -i any -w /tmp/capture.pcap &

# Make a request
curl -k https://app.team1.test/

# Stop the capture
sudo killall tcpdump
```
You can then transfer `/tmp/capture.pcap` to your local machine (using `scp`) to open in Wireshark and show to the faculty!

## 3. Deliberate Failures

For the failure demonstrations:
- **Stop one backend:** SSH into Mac 3 and run `sudo systemctl stop backend`. Then hit the API from Mac 1 to show it still works (served entirely by Mac 4).
- **Stop both backends:** SSH into Mac 4 and run `sudo systemctl stop backend` as well. Hit the API to get a `502 Bad Gateway`.
- **Wrong destination port:** Show failure connecting to `3003`.
