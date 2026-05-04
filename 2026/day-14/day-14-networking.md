# Day 14 – Networking Fundamentals & Hands-on Checks

## Quick Concepts

### OSI layers (L1–L7) vs TCP/IP stack (Link, Internet, Transport, Application)

Where IP, TCP/UDP, HTTP/HTTPS, DNS sit in the stack

OSI Model \
L7 - Application layer  -> UI - HTTP/HTTPS, DNS \
L6 - presentation layer -> Encryption\
L5 - session layer      -> Login\
L4 - transport layer    -> TCP/UDP\
L3 - Network layer      -> IP\
L2 - data link layer    -> MAC\
L1 - physical layer

TCP/IP Model\
L4 - Application layer -> HTTP/HTTPS, DNS\
L3 - Transport layer   -> TCP/UDP\
L2 - Internet layer    -> IP/route\
L1 - Network access layer -> Cable/MAC\

One real example: “curl <https://example.com> = App layer over TCP over IP”

## Hands-on Checklist

**Identity**: hostname -I (or ip addr show) — note your IP.

```sh
aishuser@aish-ubuntu-tws:~$ hostname -I
10.0.0.4 172.17.0.1
```

**Reachability**: ping <target> — mention latency and packet loss.

```sh
aishuser@aish-ubuntu-tws:~$ ping www.google.com
PING www.google.com (142.251.150.119) 56(84) bytes of data.
64 bytes from 142.251.150.119: icmp_seq=1 ttl=113 time=2.15 ms
64 bytes from 142.251.150.119: icmp_seq=2 ttl=113 time=1.98 ms
```

**Path**: traceroute <target> (or tracepath) — note any long hops/timeouts.

```sh
aishuser@aish-ubuntu-tws:~$ traceroute www.google.com
traceroute to www.google.com (142.251.152.119), 30 hops max, 60 byte packets
 1  * * *
 2  * * *
 3  * * *
 4  * * *
 5  * * *

 aishuser@aish-ubuntu-tws:~$ tracepath www.google.com
 1?: [LOCALHOST]                      pmtu 1500
 1:  no reply
 2:  no reply
 3:  no reply
 4:  no reply
 5:  no reply
```

**Ports**: ss -tulpn (or netstat -tulpn) — list one listening service and its port.\
ss -> Utility to investigate sockets\
t --tcp, u --udp, l --listening, p --processes, n --numeric

netstat -> print network connections, routing tables, interface statistics, masquerade connections, and multicast memberships

```sh
aishuser@aish-ubuntu-tws:~$ ss -tulpn
Netid  State   Recv-Q  Send-Q     Local Address:Port      Peer Address:Port  Process  
udp    UNCONN  0       0             127.0.0.54:53             0.0.0.0:*              
udp    UNCONN  0       0          127.0.0.53%lo:53             0.0.0.0:*              
udp    UNCONN  0       0          10.0.0.4%eth0:68             0.0.0.0:*              
udp    UNCONN  0       0              127.0.0.1:323            0.0.0.0:*              
udp    UNCONN  0       0                  [::1]:323               [::]:*              
tcp    LISTEN  0       4096             0.0.0.0:22             0.0.0.0:*              
tcp    LISTEN  0       511              0.0.0.0:80             0.0.0.0:*              
tcp    LISTEN  0       4096          127.0.0.54:53             0.0.0.0:*              
tcp    LISTEN  0       4096       127.0.0.53%lo:53             0.0.0.0:*              
tcp    LISTEN  0       4096           127.0.0.1:41703          0.0.0.0:*              
tcp    LISTEN  0       4096                [::]:22                [::]:*              
tcp    LISTEN  0       511                 [::]:80                [::]:* 
```

**Name resolution**: dig <domain> or nslookup <domain> — record the resolved IP.

```sh
aishuser@aish-ubuntu-tws:~$ nslookup google.com
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
Name:   google.com
Address: 142.251.215.174
Name:   google.com
Address: 2607:f8b0:4007:805::200e
```

- DNS server used:
127.0.0.53 is a local DNS resolver running on my machine (commonly used by systemd-resolved in Linux).

#53 means it’s using port 53, the standard DNS port.

- Non-authoritative answer:
So the system is not directly querying external DNS (like Google DNS), but using a local caching/forwarding resolver.

- Domain Name Resolution
Address: 142.251.215.174 - This is the IPv4 address (A record) of google.com.

- IPv6 Address
Address: 2607:f8b0:4007:805::200e - This is the IPv6 address (AAAA record) of google.com

**HTTP check**: curl -I <http/https-url> — note the HTTP status code.

```sh
aishuser@aish-ubuntu-tws:~$ curl -I www.google.com
HTTP/1.1 200 OK
```

**Connections snapshot**: netstat -an | head — count ESTABLISHED vs LISTEN (rough).

```sh
aishuser@aish-ubuntu-tws:~$ netstat -an | head
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN     
tcp        0      0 127.0.0.54:53           0.0.0.0:*               LISTEN     
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN     
tcp        0      0 127.0.0.1:41703         0.0.0.0:*               LISTEN     
tcp        0    368 10.0.0.4:22             49.37.128.206:55020     ESTABLISHED
tcp        0      0 10.0.0.4:33412          52.182.143.215:443      TIME_WAIT  
tcp        0      0 10.0.0.4:50772          104.208.16.92:443       TIME_WAIT 
```

## Mini Task: Port Probe & Interpret

Identify one listening port from ss -tulpn (e.g., SSH on 22 or a local web app).

```sh
Netid      State       Recv-Q      Send-Q                                       Local Address:Port            Peer Address:Port    Process
tcp        ESTAB       0           404                                               10.0.0.4:ssh            49.37.128.206:55020
```

From the same machine, test it: nc -zv localhost <port> (or curl -I <http://localhost>:<port>).

```sh
aishuser@aish-ubuntu-tws:~$  nc -zv localhost 22
Connection to localhost (127.0.0.1) 22 port [tcp/ssh] succeeded!
```

Write one line: is it reachable? If not, what’s the next check? (e.g., service status, firewall).
- It is reachable.
