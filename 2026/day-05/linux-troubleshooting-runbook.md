# Day 05 – Linux Troubleshooting Drill: CPU, Memory, and Logs

## Run and record output for at least 8 commands (save snippets in your runbook)

### Environment basics (2)

uname: provides various options to display the kernel name, operating system, processor type, and other system details.

```sh
aishuser@aish-ubuntu-tws:~$ uname -a
Linux aish-ubuntu-tws 6.17.0-1011-azure #11~24.04.2-Ubuntu SMP Wed Mar 25 22:46:36 UTC 2026 x86_64 x86_64 x86_64 GNU/Linux
```

lsb_release -a (or cat /etc/os-release):
a Linux utility used to display specific information about your Linux distribution and its compliance with the Linux Standard Base (LSB). It provides a standardized way to identify the OS version, codename, and distributor ID across different distributions.

```sh
aishuser@aish-ubuntu-tws:~$ lsb_release -a 
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 24.04.4 LTS
Release:        24.04
Codename:       noble
aishuser@aish-ubuntu-tws:~$ cat /etc/os-release
PRETTY_NAME="Ubuntu 24.04.4 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.4 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=noble
LOGO=ubuntu-logo
```

### Filesystem sanity (2)

Create a throwaway folder and file, e.g., mkdir /tmp/runbook-demo, cp /etc/hosts /tmp/runbook-demo/hosts-copy && ls -l /tmp/runbook-demo

```sh
aishuser@aish-ubuntu-tws:~$ mkdir /tmp/runbook-demo
aishuser@aish-ubuntu-tws:~$ cp /etc/host
host.conf    hostname     hosts        hosts.allow  hosts.deny
aishuser@aish-ubuntu-tws:~$ cp /etc/hosts /tmp/runbook-demo/hosts-copy
aishuser@aish-ubuntu-tws:~$ cp /etc/hosts /tmp/runbook-demo/hosts-copy && ls -l /tmp//runbook-demo/
total 4
-rw-r--r-- 1 aishuser aishuser 221 Apr 20 15:09 hosts-copy
```

### CPU / Memory (2)

top/htop/ps -o pid,pcpu,pmem,comm -p <pid>, free -h, vm_stat (mac)

```sh
aishuser@aish-ubuntu-tws:~$ free -h
               total        used        free      shared  buff/cache   available
Mem:           3.8Gi       785Mi       1.2Gi       4.0Mi       2.1Gi       3.0Gi
Swap:             0B          0B          0B
```

```sh
aishuser@aish-ubuntu-tws:~$ ps aux | grep nginx
root         803  0.0  0.0  11168  1736 ?        Ss   13:08   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data     804  0.0  0.1  12892  4456 ?        S    13:08   0:00 nginx: worker process
www-data     805  0.0  0.1  12892  4392 ?        S    13:08   0:00 nginx: worker process
aishuser   12522  0.0  0.1  17772  6464 pts/0    T    15:17   0:00 systemctl status nginx
aishuser   12582  0.0  0.0   7084  2172 pts/0    T    15:19   0:00 grep --color=auto nginx
aishuser   12596  0.0  0.0   7084  2164 pts/0    S+   15:20   0:00 grep --color=auto nginx
```

```sh
aishuser@aish-ubuntu-tws:~$ ps -o pid,pcpu,pmem,comm -p 803
    PID %CPU %MEM COMMAND
    803  0.0  0.0 nginx
aishuser@aish-ubuntu-tws:~$ ps -o pid,pcpu,pmem,comm -p 804
    PID %CPU %MEM COMMAND
    804  0.0  0.1 nginx
aishuser@aish-ubuntu-tws:~$ ps -o pid,pcpu,pmem,comm -p 805
    PID %CPU %MEM COMMAND
    805  0.0  0.1 nginx
```

### Disk / IO (2)

df -h, du -sh /var/log, iostat/vmstat/dstat

```sh
aishuser@aish-ubuntu-tws:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        29G   12G   17G  43% /
tmpfs           1.9G     0  1.9G   0% /dev/shm
tmpfs           774M 1012K  773M   1% /run
tmpfs           5.0M     0  5.0M   0% /run/lock
efivarfs        128K   38K   86K  31% /sys/firmware/efi/efivars
/dev/sda16      881M  170M  650M  21% /boot
/dev/sda15      105M  6.2M   99M   6% /boot/efi
tmpfs           387M   16K  387M   1% /run/user/1000

Disk usage of nginx directory
aishuser@aish-ubuntu-tws:/var/log$ du -sh /var/log/nginx/
12K     /var/log/nginx/
root@aish-ubuntu-tws:/home/aishuser# du -sh
6.2G    .
```

### Network (2)

ss -tulpn: This command will show all listening TCP connections on the system
curl -I <service-endpoint>/ping

```sh
aishuser@aish-ubuntu-tws:~$ ss -tulpn
Netid  State   Recv-Q  Send-Q     Local Address:Port      Peer Address:Port  Process  
udp    UNCONN  0       0             127.0.0.54:53             0.0.0.0:*              
udp    UNCONN  0       0          127.0.0.53%lo:53             0.0.0.0:*              
udp    UNCONN  0       0          10.0.0.4%eth0:68             0.0.0.0:*              
udp    UNCONN  0       0              127.0.0.1:323            0.0.0.0:*              
udp    UNCONN  0       0                  [::1]:323               [::]:*              
tcp    LISTEN  0       4096       127.0.0.53%lo:53             0.0.0.0:*              
tcp    LISTEN  0       4096           127.0.0.1:36329          0.0.0.0:*              
tcp    LISTEN  0       4096          127.0.0.54:53             0.0.0.0:*              
tcp    LISTEN  0       511              0.0.0.0:80             0.0.0.0:*              
tcp    LISTEN  0       4096             0.0.0.0:22             0.0.0.0:*              
tcp    LISTEN  0       511                 [::]:80                [::]:*              
tcp    LISTEN  0       4096                [::]:22                [::]:*

```

```sh
aishuser@aish-ubuntu-tws:~$ curl -I amazon.com/ping
HTTP/1.1 200 OK
Server: Server
Date: Mon, 20 Apr 2026 16:31:17 GMT
Content-Type: application/octet-stream
Content-Length: 0
Connection: keep-alive
```

### Logs (2)

journalctl -u <service> -n 50, tail -n 50 /var/log/<file>.log

```sh
aishuser@aish-ubuntu-tws:~$ journalctl -u nginx -n 50
Apr 09 17:51:29 aish-ubuntu-tws systemd[1]: Stopping nginx.service ->
Apr 09 17:51:30 aish-ubuntu-tws systemd[1]: nginx.service: Deactivat>
Apr 09 17:51:30 aish-ubuntu-tws systemd[1]: Stopped nginx.service - >
-- Boot 9b450cf3b20e417aa2516d74d06d0564 --
Apr 11 10:15:22 aish-ubuntu-tws systemd[1]: Starting nginx.service ->
Apr 11 10:15:22 aish-ubuntu-tws systemd[1]: Started nginx.service - >
Apr 11 12:02:41 aish-ubuntu-tws systemd[1]: Stopping nginx.service ->
Apr 11 12:02:41 aish-ubuntu-tws systemd[1]: nginx.service: Deactivat>
Apr 11 12:02:41 aish-ubuntu-tws systemd[1]: Stopped nginx.service - >
Apr 11 12:02:41 aish-ubuntu-tws systemd[1]: Starting nginx.service ->
Apr 11 12:02:41 aish-ubuntu-tws systemd[1]: Started nginx.service - >
Apr 11 12:05:48 aish-ubuntu-tws systemd[1]: Stopping nginx.service ->
Apr 11 12:05:48 aish-ubuntu-tws systemd[1]: nginx.service: Deactivat>
Apr 11 12:05:48 aish-ubuntu-tws systemd[1]: Stopped nginx.service - >
-- Boot 955bcc7b9dba45b085266ff70226e14a --
Apr 11 12:06:13 aish-ubuntu-tws systemd[1]: Starting nginx.service ->
Apr 11 12:06:13 aish-ubuntu-tws systemd[1]: Started nginx.service - >
Apr 11 13:58:27 aish-ubuntu-tws systemd[1]: Stopping nginx.service ->
Apr 11 13:58:27 aish-ubuntu-tws systemd[1]: nginx.service: Deactivat>
Apr 11 13:58:27 aish-ubuntu-tws systemd[1]: Stopped nginx.service - >
-- Boot 53fc7317925348debffb337749702039 --

aishuser@aish-ubuntu-tws:/var/log$ sudo tail -n 10 /var/log/nginx/access.log.1
49.37.129.192 - - [26/Mar/2026:12:24:28 +0000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36"
49.37.129.192 - - [26/Mar/2026:12:25:07 +0000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36"
49.37.129.192 - - [26/Mar/2026:12:25:08 +0000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36"
49.37.129.192 - - [26/Mar/2026:12:25:09 +0000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36"
49.37.129.192 - - [26/Mar/2026:12:25:10 +0000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36"

aishuser@aish-ubuntu-tws:/var/log$ sudo tail -n 10 /var/log/nginx/error.log.1
2026/03/26 10:51:31 [notice] 3314#3314: using inherited sockets from "5;6;"
```

If hight CPU is happening in Nginx, then we will run the 
1. PS command to check CPU. 
2. run top/htop/ps commands to get the PID
3. tail command to Check logs in error.log
4. journalctl to check service related logs
5. restart the service without killing it
6. If that does not work than kill it
