# Day 15 – Networking Concepts: DNS, IP, Subnets & Ports

## Task 1: DNS – How Names Become IPs

1. Explain in 3–4 lines: what happens when you type google.com in a browser?

- HTTPS protocol used
- DNS resolves the google.com to it's IP address
- The request goes to google server
- and the response returns as google search page

2. What are these record types? Write one line each:
A (Address Record) - Maps a domain name directly to an IPV4 address
AAAA (Quad-A record) -  Maps a domain name to an IPv6 address
CNAME (Canonical Name Record/alias record) - maps a subdomain/alias name to another domain
MX (Mail Exchange) - Directs email traffic to the appropriate email server for the domain.
NS (Authoritative Name server) - Identifies which DNS servers are authoritative for a domain — which servers hold the actual DNS records.

3. Run: dig google.com — identify the A record and TTL from the output

```sh
aishuser@aish-ubuntu-tws:~$ dig google.com

; <<>> DiG 9.18.39-0ubuntu0.24.04.3-Ubuntu <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 62740
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;google.com.                    IN      A

;; ANSWER SECTION:
google.com.             119     IN      A       142.251.40.110

;; Query time: 1 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Sun May 03 15:12:20 UTC 2026
;; MSG SIZE  rcvd: 55

```

119 → TTL (Time To Live, in seconds)
DNS result will be cached for 119 seconds

A → IPv4 record
142.251.40.110 → resolved IP address

## Task 2: IP Addressing

What is an IPv4 address? How is it structured? (e.g., 192.168.1.10)

- unique 32-bit numerical identifier assigned to devices connected to a network, used to route traffic.
- It is structured as four 8-bit decimal numbers (octets) ranging from 0–255, separated by periods, such as 192.168.1.1
- It consists of a network ID and a host ID.

Difference between public and private IPs — give one example of each
Public IP:

- It is visible to the internet
- The public IP is provided by ISP
- Globally Unique
- Costs money

Private IP:

- It is hidden and used only on local networks
- Private IPs are assigned by the local router
- Unique within your local network
- These are free

What are the private IP ranges?

- 10.x.x.x, 172.16.x.x – 172.31.x.x, 192.168.x.x

Run: ip addr show — identify which of your IPs are private

## Task 3: CIDR & Subnetting

What does /24 mean in 192.168.1.0/24?

- First 3 octets are fixed and only last 8 bits can be changed.
192.168.1 -> Fixed octets

How many usable hosts in a 
/24?    -> subnet mask (255.255.255.0)
Total IPs - 2^8 = 256
Reserved IPs - 2 (network add + broadcast add)
Usable Host add -> 254

A /16?  -> mask (255.255.0.0)
Total IP Addresses: 2^16 = 65,536
Usable Hosts: 65,534
Host Bits: 16 (since 32 - 16 = 16)

A /28?  -> mask (255.255.255.240)
Total IP Addresses: 2^4 = 16
Usable Hosts: 16-2 = 14
Host Bits: 4 (since 32 - 28 = 4)

Explain in your own words: why do we subnet?

- To isolate and make partitions of the large network.
- improves network performance, increase security, and efficiently manage IP address space

### Quick exercise — fill in

CIDR    Subnet Mask     Total IPs   Usable Hosts
/24     255.255.255.0     256        254
/16     255.255.0.0       65536      65534
/28     255.255.255.240   16         14

## Task 4: Ports – The Doors to Services

What is a port? Why do we need them?

- Acts as a digital door, directing traffic to the correct application.
- Software-based endpoint, managed by OS which identifies specific services, allowing multiple applications to send and recieve data simultaneously over one network connection.
- Ensure, traffic from 2 different services do not mixup.
- Important for firewalls to allow or block specific port for specific servie related traffic.

Document these common ports:
Port    Service
22      SSH
80      HTTP
443     HTTPS
53      Domain name server
3306    MySQL
6379    Redis
27017   MongoDB

Run ss -tulpn — match at least 2 listening ports to their services

```sh
Netid   State    Recv-Q   Send-Q     Local Address:Port      Peer Address:Port      Process                                
tcp     LISTEN   0        511              0.0.0.0:80             0.0.0.0:*       users:(("nginx",pid=815,fd=5),("nginx",pid=814,fd=5),("nginx",pid=813,fd=5))    
tcp     LISTEN   0        4096             0.0.0.0:22             0.0.0.0:*       users:(("sshd",pid=4342,fd=3),("systemd",pid=1,fd=93))                          
tcp     LISTEN   0        4096          127.0.0.54:53             0.0.0.0:*       users:(("systemd-resolve",pid=441,fd=17))                                       
tcp     LISTEN   0        4096       127.0.0.53%lo:53             0.0.0.0:*       users:(("systemd-resolve",pid=441,fd=15))                                       
tcp     LISTEN   0        511                 [::]:80                [::]:*       users:(("nginx",pid=815,fd=6),("nginx",pid=814,fd=6),("nginx",pid=813,fd=6))    
tcp     LISTEN   0        4096                [::]:22                [::]:*       users:(("sshd",pid=4342,fd=4),("systemd",pid=1,fd=94))          
```

Ports = doors
LISTEN = door open
0.0.0.0 = open to everyone
127.0.0.1 = only inside the house

- system is running:

Local DNS resolver (127.0.0.53)
Web server on port 80
SSH server on port 22

## Task 5: Putting It Together

Answer in 2–3 lines each:

You run curl <http://myapp.com:8080> — what networking concepts from today are involved?

- port 8080 will be used
- The domain myapp.com will be resolved for it's IP address with which the server hosting the app will be identified and requested for the app on port 8080.

Your app can't reach a database at 10.0.1.50:3306 — what would you check first?

- if the port is open for the right IP range or not
- The database is running on 3306 or not
