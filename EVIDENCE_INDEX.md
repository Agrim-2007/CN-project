# Evidence Index

This document maps all the evidence required for Phase 1. As you complete the steps and take screenshots or save terminal outputs, you will place them in the `evidence/` folder and link them here.

## Task A — LAN setup (network info, ping)
- [ ] `evidence/task_a_ping.txt` (Ping from Mac 1 to all other Macs)

## Task B — Private DNS resolution
- [ ] `evidence/task_b_dns_resolution.txt` (Output of `dig app.team1.test` from Mac 1)

## Task C — Backend REST services
- [ ] `evidence/task_c_backend_status.txt` (Output showing both backends are running)

## Task D — Edge reverse proxy + load balancer
- [ ] `evidence/task_d_load_balancing.txt` (Repeated curl requests showing alternating X-Backend headers)

## Task E — TLS
- [ ] `evidence/task_e_tls_handshake.txt` (Output of `curl -v` showing the TLS handshake details)

## Task F — HTTP caching
- [ ] `evidence/task_f_caching.txt` (Output of `curl -I` showing the `Cache-Control` header)

## Task G — Full protocol-flow packet captures
- [ ] `evidence/task_g_capture.pcap` (Wireshark capture file)

## Phase 1 Failure Demonstrations
- [ ] **Failure 1 (Wrong DNS server):** `evidence/failure_1_wrong_dns.txt`
- [ ] **Failure 2 (Wrong DNS record):** `evidence/failure_2_wrong_record.txt`
- [ ] **Failure 3 (One backend stopped):** `evidence/failure_3_one_backend_down.txt`
- [ ] **Failure 4 (Both backends stopped):** `evidence/failure_4_both_backends_down.txt`
- [ ] **Failure 5 (Wrong destination port):** `evidence/failure_5_wrong_port.txt`
