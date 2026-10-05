# Video Presentation Script (Solo AWS Edition)

Since you are presenting this alone using 4 AWS EC2 instances to simulate the 4 laptops, here is your customized, step-by-step video script based on the exact requirements of the project.

**Setup before recording:**
Open 4 different terminal tabs on your computer (or CloudShell). SSH into each of your 4 machines in a different tab so you can quickly switch between them during the video.
* Tab 1: `ssh ubuntu@<MAC1_IP>`
* Tab 2: `ssh ubuntu@<MAC2_IP>`
* Tab 3: `ssh ubuntu@<MAC3_IP>`
* Tab 4: `ssh ubuntu@<MAC4_IP>`

---

## Part 1: Intro & Happy Path

**You:** "Hi, this is my Phase 1 demo of a private network service platform. Because I do not have 4 physical laptops, I am simulating the 4 required machines using 4 AWS EC2 instances in a completely isolated Private Cloud (VPC). The network is `10.0.1.0/24`."

*(Switch to Tab 3 - Mac 3)*
**You:** "Here is Mac 3, our Backend A. As you can see by running `systemctl status backend`, the python server is up and listening on port 3001."

*(Switch to Tab 4 - Mac 4)*
**You:** "Here is Mac 4, our Backend B. It is up and running on port 3002."

*(Switch to Tab 1 - Mac 1)*
**You:** "Here is Mac 1, our DNS server. dnsmasq is running. When I run `dig app.team1.test`, it correctly resolves to our edge IP: `10.0.1.20`."

*(Switch to Tab 2 - Mac 2)*
**You:** "Here is Mac 2, our Nginx Edge proxy. It handles load balancing and TLS termination."

*(Switch back to Tab 1 - Mac 1 to act as the client)*
**You:** "When I `curl` our HTTPS endpoint repeatedly from the client..."
*(Run `curl -k -I https://app.team1.test/api/status` 3 or 4 times)*
**You:** "...you can see the `X-Backend` header alternating between A and B. Our load balancer is working, and the TLS certificate is working. You also see the `Cache-Control` header for caching."

---

## Part 2: The 5 Failure Demos

**You:** "Now for the failure demos."

**Failure 1: Wrong DNS server**
*(Stay in Tab 1)*
**You:** "For Failure 1, I will change my client's DNS to something wrong, like 8.8.8.8."
*(Run: `sudo resolvectl dns eth0 8.8.8.8`)*
**You:** "When I ping our domain `ping -c 1 app.team1.test`, it fails. But when I ping the IP directly `ping -c 1 10.0.1.20`, it works, proving the network is fine but DNS is broken."
*(Run: `sudo resolvectl dns eth0 10.0.1.10` to fix it).*

**Failure 2: DNS points to wrong IP**
*(Stay in Tab 1)*
**You:** "For Failure 2, I will point our dnsmasq record to a fake IP."
*(Run: `sudo sed -i 's/10.0.1.20/10.0.1.99/g' /etc/dnsmasq.conf && sudo systemctl restart dnsmasq`)*
**You:** "Now when I `dig app.team1.test`, it resolves to `.99`. The DNS works, but it routes to the wrong destination."
*(Run: `sudo sed -i 's/10.0.1.99/10.0.1.20/g' /etc/dnsmasq.conf && sudo systemctl restart dnsmasq` to fix it).*

**Failure 3: One backend stopped**
*(Switch to Tab 3)*
**You:** "For Failure 3, I am now stopping Backend A."
*(Run: `sudo systemctl stop backend`)*
*(Switch to Tab 1)*
**You:** "When I curl the API repeatedly..."
*(Run: `curl -k -I https://app.team1.test/api/status` 3 times)*
**You:** "...there are zero errors, but traffic is now 100% routed to Backend B. Nginx handled the failover perfectly."

**Failure 4: Both backends stopped**
*(Switch to Tab 4)*
**You:** "For Failure 4, I am now stopping Backend B. Both application servers are completely down."
*(Run: `sudo systemctl stop backend`)*
*(Switch to Tab 1)*
**You:** "When I curl the API now..."
*(Run: `curl -k -I https://app.team1.test/api/status`)*
**You:** "...Nginx returns a 502 Bad Gateway error. The edge is alive, but the backends are unreachable." 
*(Go back to Tab 3 and Tab 4 and run `sudo systemctl start backend` on both).*

**Failure 5: Wrong destination port**
*(Switch to Tab 1)*
**You:** "For Failure 5, I am testing a wrong destination port. I can successfully ping the Edge IP (`ping -c 1 10.0.1.20`), proving the machine is online. But when I curl a fake port..."
*(Run: `curl -v http://10.0.1.20:9999`)*
**You:** "...it immediately says 'Connection refused', because nothing is listening there."

---

## Part 3: Protocol Capture

*(Stay in Tab 1)*
**You:** "Finally, here is the full protocol flow. I will run a packet capture using `tcpdump`."
*(Run: `sudo tcpdump -i eth0 port 53 or port 443 -w capture.pcap &`)*
*(Run: `curl -k https://app.team1.test/api/status`)*
*(Run: `sudo killall tcpdump`)*

**You:** "This generates a PCAP file. If we open this in Wireshark:"
1. "First, we would see the DNS Layer 7 request and response returning our Edge IP."
2. "Next, we see the TCP 3-way handshake (SYN, SYN-ACK, ACK) at Layer 4 establishing the connection on port 443."
3. "Right after is the TLS handshake securing the session."
4. "And finally, the 'Application Data' packets are our HTTP traffic, completely encrypted by TLS."

*(You can download `capture.pcap` from Mac 1 to your local computer if you want to actually open it in Wireshark on screen).*
