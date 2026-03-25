#### **Process management commands**

1. **top** - Can display system summary info and a list of processes or threads currently being managed by kernel.

   * Shows live system stats (CPU, memory, load average)
   * Updates continuously (default every \~3 seconds)
   * Allows basic interaction via keyboard, mouse is not supported.
2. **htop** - interactive process viewer. View running processes with their cmd line arguments.

   * Modern alternative to top
   * Supports mouse clicks
   * Easy sorting, filtering, and process tree view
3. **ps** - Displays a one-time snapshot of processes

   * No real-time updates



###### **When to use What:**

Use top → when you want quick real-time stats on any machine



Use htop → when you want a better UI + easier control



Use ps → when you need precise, scriptable output



**5. kill - send a TERM signal to a process**

**6. nice -  run a program with modified scheduling priority**

**7. renice - alter priority of running processes**



###### **Nice Value:**

* **Controls CPU scheduling priority**
* **ranges from -20 to 19. priority (Highest (-20), default (0), lowest (19))**
* **Lower value = more CPU priority | Higher value = less CPU priority (more “nice” to others)**



#### **File system commands**

1. **ls - list directory contents**
2. **pwd - print name of current working directory**
3. **cd - change directory**
4. **mv - move files and directories**
5. **cp - copy files and directories**
6. **rm - remove files and directories**
7. **rmdir - remove empty directories**
8. **mkdir - create directories**
9. **touch - create files**
10. **cat - print content of the file**
11. **grep - search for patterns in each file**
12. **find - search for files in a directory hierarchy**
13. **chmod - change file permissions**
14. **chown - change file owner and group**
15. **chgrp - change group ownership**
16. **df (disk free)- shows disk usage status**
17. **du (disk usage)- shows file/folder usage inside that disk**
18. **tar- archive the files**
19. **ln - make links between files**
20. **head/tail - output the first/last part of the files**
21. **man - an interface to the system reference manuals**





#### **Networking troubleshooting commands**

1. **ping - uses ICMP protocol to send echo request and receive a echo response from a host or gateway**
2. **telnet - Test if a port on a remote server is open and reachable**
3. **host - DNS lookup utility. normally used to convert names to IP addresses and vice versa**
4. **dig - deep DNS lookup utility.** 
5. **ip - show / manipulate routing, network devices, interfaces and tunnels**
6. **ip addr - show IP addresses**
7. **traceroute - shows every stop (router) between you and a destination**
8. **curl -  transferring data from or to a server using URLs. It supports wide number of protocols**
9. **wget - on-interactive download of files from the Web. It supports HTTP, HTTPS, and FTP protocols, as well as retrieval through HTTP proxies**
10. **tcpdump - capture and analyze network packets in real time**
11. **nmap - scan networks and discover open ports, services, and hosts** 
12. **nslookup - query Internet domain name servers**



