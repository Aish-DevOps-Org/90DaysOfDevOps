# Day 07 – Linux File System Hierarchy & Scenario-Based Practice

## Part 1: Linux File System Hierarchy

Core Directories (Must Know):

- / (root) - The starting point of everything
The top-most level of the file system hierarchy. Servcie as the trunk from which all the other files and directories branch out.

```sh
aishuser@aish-ubuntu-tws:/$ pwd
/
aishuser@aish-ubuntu-tws:/$ ls -lrta
total 92
drwxr-xr-x   2 root root  4096 Feb 26  2024 bin.usr-is-merged
drwxr-xr-x   2 root root  4096 Mar 31  2024 sbin.usr-is-merged
drwxr-xr-x   2 root root  4096 Apr  8  2024 lib.usr-is-merged
lrwxrwxrwx   1 root root     8 Apr 22  2024 sbin -> usr/sbin
lrwxrwxrwx   1 root root     9 Apr 22  2024 lib64 -> usr/lib64
lrwxrwxrwx   1 root root     7 Apr 22  2024 lib -> usr/lib
lrwxrwxrwx   1 root root     7 Apr 22  2024 bin -> usr/bin
drwxr-xr-x   2 root root  4096 Mar 12 04:20 srv
drwxr-xr-x   2 root root  4096 Mar 12 04:20 media
drwxr-xr-x  12 root root  4096 Mar 12 04:20 usr
drwx------   2 root root 16384 Mar 12 04:27 lost+found
drwxr-xr-x   3 root root  4096 Mar 25 11:29 home
drwxr-xr-x   2 root root  4096 Mar 25 11:29 snap
drwxr-xr-x  14 root root  4096 Mar 26 10:51 var
drwx------   4 root root  4096 Mar 27 16:27 root
drwxr-xr-x   5 root root  4096 Mar 27 16:51 mnt
drwxr-xr-x   5 root root  4096 Apr 11 12:02 boot
drwxr-xr-x   4 root root  4096 Apr 20 14:07 opt
drwxr-xr-x 126 root root 12288 Apr 20 15:15 etc
dr-xr-xr-x  12 root root     0 Apr 26 11:14 sys
dr-xr-xr-x 184 root root     0 Apr 26 11:14 proc
drwxr-xr-x  22 root root  4096 Apr 26 11:14 ..
drwxr-xr-x  22 root root  4096 Apr 26 11:14 .
drwxr-xr-x  18 root root  3980 Apr 26 11:14 dev
drwxr-xr-x  33 root root  1100 Apr 26 11:17 run
drwxrwxrwt  12 root root  4096 Apr 26 11:29 tmp
```

- /home - User home directories
Home directories of all the users except root user, exists here.

```sh
aishuser@aish-ubuntu-tws:/home$ pwd
/home
aishuser@aish-ubuntu-tws:/home$ ls
aishuser
aishuser@aish-ubuntu-tws:/home$
```

- /root - Root user's home directory
We can cd into root dir only with sudo privilege.

```sh
aishuser@aish-ubuntu-tws:/$ cd root
-bash: cd: root: Permission denied
aishuser@aish-ubuntu-tws:/$ sudo su
root@aish-ubuntu-tws:/# pwd
/
root@aish-ubuntu-tws:/# cd root/
root@aish-ubuntu-tws:~# ls
root@aish-ubuntu-tws:~#
```

- /etc - Configuration files
Historically - Et Cetera (meaning "and the rest")
Currently - standard location for system-wide configuration files. This led to the popular backronym "Editable Text Configuration" to better describe its current function. Some also refer to it as "Everything To Configure".

 Contains nearly all the settings for your system, such as user account details (/etc/passwd), network hostnames (/etc/hostname), and disk mount instructions (/etc/fstab).

Use this for host details, group details, user details, file system.

```sh
aishuser@aish-ubuntu-tws:/etc$ ls
ModemManager            hosts.allow             profile
NetworkManager          hosts.deny              profile.d
PackageKit              init                    protocols
X11                     init.d                  pulse
adduser.conf            initramfs-tools         python3
alternatives            inputrc                 python3.12
apparmor                iproute2                rc0.d
apparmor.d              iscsi                   rc1.d
apport                  issue                   rc2.d
apt                     issue.net               rc3.d
bash.bashrc             kernel                  rc4.d
bash_completion         keyutils                rc5.d
bash_completion.d       landscape               rc6.d
bindresvport.blacklist  ld.so.cache             rcS.d
binfmt.d                ld.so.conf              request-key.conf
byobu                   ld.so.conf.d            request-key.d
ca-certificates         ldap                    resolv.conf
ca-certificates.conf    legal                   rmt
chrony                  libaudit.conf           rpc
cifs-utils              libblockdev             rsyslog.conf
cloud                   libibverbs.d            rsyslog.d
cni                     libnl-3                 screenrc
console-setup           locale.alias            security
credstore               locale.conf             selinux
credstore.encrypted     locale.gen              sensors.d
cron.d                  localtime               sensors3.conf
cron.daily              logcheck                services
cron.hourly             login.defs              sgml
cron.monthly            logrotate.conf          shadow
cron.weekly             logrotate.d             shadow-
cron.yearly             lsb-release             shells
crontab                 lvm                     skel
cryptsetup-initramfs    machine-id              sos
crypttab                magic                   ssh
dbus-1                  magic.mime              ssl
dconf                   manpath.config          subgid
debconf.conf            mdadm                   subgid-
debian_version          mime.types              subuid
default                 mke2fs.conf             subuid-
deluser.conf            modprobe.d              sudo.conf
depmod.d                modules                 sudo_logsrvd.conf
dhcp                    modules-load.d          sudoers
dhcpcd.conf             mtab                    sudoers.d
dictionaries-common     multipath               supercat
dnsmasq.d               multipath.conf          sysctl.conf
docker                  nanorc                  sysctl.d
dpkg                    needrestart             sysstat
e2scrub.conf            netconfig               systemd
ec2_version             netplan                 terminfo
emacs                   network                 timezone
environment             networkd-dispatcher     tmpfiles.d
environment.d           networks                ubuntu-advantage
ethertypes              newt                    ucf.conf
fonts                   nftables.conf           udev
fstab                   nginx                   udisks2
fuse.conf               nsswitch.conf           ufw
fwupd                   nvme                    update-manager
gai.conf                opt                     update-motd.d
glvnd                   os-release              update-notifier
gnutls                  overlayroot.conf        usb_modeswitch.conf
groff                   overlayroot.local.conf  usb_modeswitch.d
group                   pam.conf                vconsole.conf
group-                  pam.d                   vim
grub.d                  passwd                  vmware-tools
gshadow                 passwd-                 vtrgb
gshadow-                perl                    vulkan
gss                     pki                     waagent.conf
gtk-3.0                 plymouth                wgetrc
hdparm.conf             pm                      xattr.conf
host.conf               polkit-1                xdg
hostname                pollinate               xml
hosts                   ppp                     zsh_command_not_found
```

- /var/log - Log files (very important for DevOps!)
standard location for storing log files, containing records of system activity (/var/log/syslog), security events (/var/log/auth.log) and application data (/var/log/apache2, /var/log/mysql, /var/log/dpkg.log etc).

```sh
aishuser@aish-ubuntu-tws:/var/log$ ls
README                 cloud-init.log.2.gz  lastlog
alternatives.log       dist-upgrade         microsoft
alternatives.log.1     dmesg                nginx
apport.log             dmesg.0              private
apport.log.1           dmesg.1.gz           syslog
apt                    dmesg.2.gz           syslog.1
auth.log               dmesg.3.gz           syslog.2.gz
auth.log.1             dmesg.4.gz           syslog.3.gz
auth.log.2.gz          dpkg.log             syslog.4.gz
auth.log.3.gz          dpkg.log.1           sysstat
auth.log.4.gz          fontconfig.log       ubuntu-advantage-apt-hook.log
azure                  journal              ubuntu-advantage.log
btmp                   kern.log             ubuntu-advantage.log.1
btmp.1                 kern.log.1           unattended-upgrades
chrony                 kern.log.2.gz        waagent.log
cloud-init-output.log  kern.log.3.gz        wtmp
cloud-init.log         kern.log.4.gz
cloud-init.log.1       landscape
```

Additional details

```sh
/var/log/utmp tracks currently logged-in users -> 
aishuser@aish-ubuntu-tws:/var/log$ who
aishuser pts/0        2026-04-26 11:17 (49.37.128.206)
aishuser@aish-ubuntu-tws:/var/log$ whoami
aishuser

/var/log/wtmp records all historical logins and logouts ->
aishuser@aish-ubuntu-tws:/var/log$ last
aishuser pts/0        49.37.128.206    Sun Apr 26 11:17   still logged in
reboot   system boot  6.17.0-1011-azur Sun Apr 26 11:14   still running
aishuser pts/0        49.37.128.206    Mon Apr 20 16:29 - 17:29  (01:00)
aishuser pts/0        49.37.128.206    Mon Apr 20 16:09 - 16:24  (00:14)
aishuser pts/0        49.37.128.206    Mon Apr 20 14:57 - 15:37  (00:39)
aishuser pts/0        49.37.128.206    Mon Apr 20 13:57 - 14:14  (00:17)
aishuser pts/0        49.37.128.206    Mon Apr 20 13:11 - 13:21  (00:09)
reboot   system boot  6.17.0-1011-azur Mon Apr 20 13:08 - 17:29  (04:21)
aishuser pts/0        49.37.128.206    Sat Apr 18 13:49 - 14:16  (00:26)
aishuser pts/0        49.37.128.206    Sat Apr 18 13:43 - 13:48  (00:05)
aishuser pts/0        49.37.128.206    Sat Apr 18 12:51 - 13:34  (00:42)
aishuser pts/1        49.37.128.206    Sat Apr 18 12:27 - 13:33  (01:06)
aishuser pts/0        49.37.128.206    Sat Apr 18 12:16 - 12:50  (00:34)
reboot   system boot  6.17.0-1011-azur Sat Apr 18 12:14 - 17:38  (05:23)
aishuser pts/1        49.37.128.206    Sat Apr 18 09:06 - 10:03  (00:57)
aishuser pts/0        49.37.128.206    Sat Apr 18 08:36 - 10:03  (01:27)
reboot   system boot  6.17.0-1011-azur Sat Apr 18 08:31 - 10:03  (01:32)
aishuser pts/1        49.37.128.206    Thu Apr 16 17:47 - 17:49  (00:01)
aishuser pts/0        49.37.128.206    Thu Apr 16 17:41 - 17:49  (00:07)
aishuser pts/0        49.37.128.206    Thu Apr 16 17:29 - 17:40  (00:11)
aishuser pts/0        49.37.128.206    Thu Apr 16 13:26 - 13:59  (00:33)
aishuser pts/1        49.37.128.206    Thu Apr 16 12:27 - 13:09  (00:42)
aishuser pts/0        49.37.128.206    Thu Apr 16 11:54 - 13:10  (01:16)
aishuser pts/0        52.163.67.188    Thu Apr 16 11:48 - 11:52  (00:03)

/var/log/lastlog contains the last login time for each user ->
aishuser@aish-ubuntu-tws:/var/log$ lastlog
Username         Port     From                                       Latest
root                                                                **Never logged in**
daemon                                                              **Never logged in**
bin                                                                 **Never logged in**
sys                                                                 **Never logged in**
sync                                                                **Never logged in**
games                                                               **Never logged in**
man                                                                 **Never logged in**
lp                                                                  **Never logged in**
mail                                                                **Never logged in**
news                                                                **Never logged in**
uucp                                                                **Never logged in**
proxy                                                               **Never logged in**
www-data                                                            **Never logged in**
backup                                                              **Never logged in**
list                                                                **Never logged in**
irc                                                                 **Never logged in**
_apt                                                                **Never logged in**
nobody                                                              **Never logged in**
systemd-network                                                     **Never logged in**
systemd-timesync                                                    **Never logged in**
dhcpcd                                                              **Never logged in**
messagebus                                                          **Never logged in**
syslog                                                              **Never logged in**
systemd-resolve                                                     **Never logged in**
uuidd                                                               **Never logged in**
tss                                                                 **Never logged in**
sshd                                                                **Never logged in**
pollinate                                                           **Never logged in**
tcpdump                                                             **Never logged in**
landscape                                                           **Never logged in**
fwupd-refresh                                                       **Never logged in**
polkitd                                                             **Never logged in**
_chrony                                                             **Never logged in**
aishuser         pts/0    49.37.128.206                             Sun Apr 26 11:17:21 +0000 2026
mdatp                                                               **Never logged in**
dnsmasq                                                             **Never logged in**
```

- /tmp - Temporary files
Store temporary files required by the operating system, drwxrwxrwt  12 root root  4096 Apr 26 12:01 tmpapplications, and users

It typically has 1777 permissions. Sticky bit - which allows any user to create files but ensures only the file's owner (or root) can delete them

**drwxrwxrwt**  12 root root  4096 Apr 26 12:01 tmp

```sh
aishuser@aish-ubuntu-tws:/tmp$ ls
snap-private-tmp
systemd-private-6f80f5be38464a3698666cb364ace089-ModemManager.service-ilBmdb
systemd-private-6f80f5be38464a3698666cb364ace089-chrony.service-DLuR2J
systemd-private-6f80f5be38464a3698666cb364ace089-polkit.service-Eqf3ux
systemd-private-6f80f5be38464a3698666cb364ace089-systemd-logind.service-D2shju
systemd-private-6f80f5be38464a3698666cb364ace089-systemd-resolved.service-HwvxZG
```

### Additional Directories (Good to Know):

- /bin - Essential command binaries
holds essential command binaries required for booting and running the system (e.g., ls, cd, cat), available to all users.

```sh
aishuser@aish-ubuntu-tws:/bin$ ls -l | head -n 20
total 485648
lrwxrwxrwx 1 root root            4 Feb 10  2024 NF -> col1
-rwxr-xr-x 1 root root       133672 Sep 23  2025 VGAuthService
lrwxrwxrwx 1 root root            1 Apr  8  2024 X11 -> .
-rwxr-xr-x 1 root root        55744 Jan 23 13:30 [
-rwxr-xr-x 1 root root        18744 Feb 20 23:51 aa-enabled
-rwxr-xr-x 1 root root        18744 Feb 20 23:51 aa-exec
-rwxr-xr-x 1 root root        18736 Feb 20 23:51 aa-features-abi
-rwxr-xr-x 1 root root         1622 Mar 19 11:44 acpidbg
-rwxr-xr-x 1 root root         4934 Aug  3  2024 activate-global-python-argcomplete
-rwxr-xr-x 1 root root        14488 May 11  2024 acyclic
-rwxr-xr-x 1 root root        16422 Jan  5 16:17 add-apt-repository
-rwxr-xr-x 1 root root        14720 Mar  6 16:00 addpart
-rwxr-xr-x 1 root root          217 Mar  9  2024 ansible
-rwxr-xr-x 1 root root          237 Mar  9  2024 ansible-community
-rwxr-xr-x 1 root root          218 Mar  9  2024 ansible-config
-rwxr-xr-x 1 root root          247 Mar  9  2024 ansible-connection
-rwxr-xr-x 1 root root          219 Mar  9  2024 ansible-console
-rwxr-xr-x 1 root root          215 Mar  9  2024 ansible-doc
-rwxr-xr-x 1 root root          218 Mar  9  2024 ansible-galaxy
```

- /usr/bin - User command binaries
/usr/bin (User System Resources) contains the bulk of non-essential, application-level commands, such as git, python, or firefox, used in normal operations.

- /opt - Optional/third-party applications

```sh
aishuser@aish-ubuntu-tws:/opt$ ls
containerd  microsoft
```

### Hands-on task

#### Find the largest log file in /var/log

du -sh /var/log/* 2>/dev/null | sort -h | tail -5

```SH
aishuser@aish-ubuntu-tws:/dev$ du -sh /var/log/* 2>/dev/null | sort -h | tail -5
1.1M    /var/log/cloud-init.log.1
1.7M    /var/log/waagent.log
2.4M    /var/log/azure
23M     /var/log/microsoft
349M    /var/log/journal
```

2>/dev/null -> will filter out the errors so that they will not be output to our console like below.
2 represents the error descriptor, which is where errors are written to. By default they are printed out on the console. /dev/null is the standard Linux device where you send output that you want ignored

```sh
aishuser@aish-ubuntu-tws:/dev$ du -sh /var/log/* | sort -h | tail -5
du: cannot read directory '/var/log/azure/Microsoft.CPlat.Core.LinuxPatchExtension/events': Permission denied
du: cannot read directory '/var/log/azure/Microsoft.Azure.AzureDefenderForServers.MDE.Linux/events': Permission denied
du: cannot read directory '/var/log/chrony': Permission denied
du: cannot read directory '/var/log/private': Permission denied
1.1M    /var/log/cloud-init.log.1
1.7M    /var/log/waagent.log
2.4M    /var/log/azure
23M     /var/log/microsoft
349M    /var/log/journal
```

#### Look at a config file in /etc

cat /etc/hostname

```sh
aishuser@aish-ubuntu-tws:/dev$ cat /etc/hostname
aish-ubuntu-tws
```

## Part 2: Scenario-Based Practice

### Scenario 1: Service Not Starting

A web application service called 'myapp' failed to start after a server reboot.
What commands would you run to diagnose the issue?
Write at least 4 commands in order.

```sh
Step-1 - systemctl status nginx
Why: Check the status if the servcie is running or stopped

Step-2 - systemctl is-enabled
Why: To know if the service will start automatically after reboot 
aishuser@aish-ubuntu-tws:~$ systemctl is-enabled nginx
enabled

Step-3 - journalctl
Why: check logs for any failures
aishuser@aish-ubuntu-tws:~$ journalctl -u nginx -n 50
Apr 11 12:05:48 aish-ubuntu-tws systemd[1]: Stopping nginx.service - A hig>
Apr 11 12:05:48 aish-ubuntu-tws systemd[1]: nginx.service: Deactivated suc>
Apr 11 12:05:48 aish-ubuntu-tws systemd[1]: Stopped nginx.service - A high>
-- Boot 955bcc7b9dba45b085266ff70226e14a --
Apr 11 12:06:13 aish-ubuntu-tws systemd[1]: Starting nginx.service - A hig>
Apr 11 12:06:13 aish-ubuntu-tws systemd[1]: Started nginx.service - A high>
Apr 11 13:58:27 aish-ubuntu-tws systemd[1]: Stopping nginx.service - A hig>
Apr 11 13:58:27 aish-ubuntu-tws systemd[1]: nginx.
-- Boot a9c4e635c9f54a05bb20787089807cbe --
```

### Scenario 2: High CPU Usage

Your manager reports that the application server is slow.
You SSH into the server. What commands would you run to identify
which process is using high CPU?

```sh
Step-1 - ps aux --sort=-%cpu | head -10
Why: check top 10 processes running with high CPU and get the PID

aishuser@aish-ubuntu-tws:~$ ps aux --sort=-%cpu | head -10
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root       15947  0.1  2.4 893452 96196 ?        Sl   12:00   0:12 /opt/microsoft/mdatp/sbin/wdavdaemon edr 17 16 --log_level info
root       15901  0.1  4.1 1012900 165328 ?      Ssl  12:00   0:10 /opt/microsoft/mdatp/sbin/wdavdaemon
root           1  0.0  0.3  22656 14148 ?        Ss   11:14   0:08 /usr/lib/systemd/systemd --system --deserialize=73
root       15856  0.0  0.9 412556 37400 ?        Sl   12:00   0:05 /usr/bin/python3 -u bin/WALinuxAgent-2.15.1.3-py3.12.egg -run-exthandlers
root         346  0.0  0.0   3724  2728 ?        Ss   11:14   0:05 /usr/lib/linux-tools/6.17.0-1011-azure/hv_kvp_daemon -n
root         817  0.0  1.2 1792760 50636 ?       Ssl  11:14   0:03 /usr/bin/containerd
aishuser   19233  0.0  0.2  20376 11608 ?        Ss   13:43   0:00 /usr/lib/systemd/systemd --user
_chrony    15760  0.0  0.0  11216  3636 ?        S    11:59   0:01 /usr/sbin/chronyd -F 1
aishuser   19341  0.0  0.1  14976  7188 ?        S    13:43   0:00 sshd: aishuser@pts/0

Step-2 - htop 
Why: see real time running processes and then sort by %cpu and get the PID
```

### Scenario 3: Finding Service Logs

A developer asks: "Where are the logs for the 'docker' service?"
The service is managed by systemd.
What commands would you use?

```sh
Step-1: systemctl status docker
Why: check service status

aishuser@aish-ubuntu-tws:~$ sudo systemctl status docker
● docker.service - Docker Application Container Engine
     Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; preset:>
     Active: active (running) since Sun 2026-04-26 11:14:17 UTC; 2h 41min ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 1160 (dockerd)
      Tasks: 10
     Memory: 110.3M (peak: 112.6M)
        CPU: 1.043s
     CGroup: /system.slice/docker.service
             └─1160 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/co>

Apr 26 11:14:16 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:16.4004>
Apr 26 11:14:16 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:16.4711>
Apr 26 11:14:16 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:16.4762>
Apr 26 11:14:17 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:17.6472>
Apr 26 11:14:17 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:17.6876>
Apr 26 11:14:17 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:17.6901>
Apr 26 11:14:17 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:17.8474>
Apr 26 11:14:17 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:17.8583>
Apr 26 11:14:17 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:17.8584>
Apr 26 11:14:17 aish-ubuntu-tws systemd[1]: Started docker.service - Docker A>

Step-2 - journalctl 
why: check logs for any errors

aishuser@aish-ubuntu-tws:~$ journalctl -u docker -n 10
Apr 26 11:14:16 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:16.4004>
Apr 26 11:14:16 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:16.4711>
Apr 26 11:14:16 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:16.4762>
Apr 26 11:14:17 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:17.6472>
Apr 26 11:14:17 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:17.6876>
Apr 26 11:14:17 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:17.6901>
Apr 26 11:14:17 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:17.8474>
Apr 26 11:14:17 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:17.8583>
Apr 26 11:14:17 aish-ubuntu-tws dockerd[1160]: time="2026-04-26T11:14:17.8584>
Apr 26 11:14:17 aish-ubuntu-tws systemd[1]: Started docker.service - Docker A>
lines 1-10/10 (END)

step-3: journalctl -u docker -f
why: check logs in real-time
```

#### Scenario 4: File Permissions Issue

A script at /home/user/backup.sh is not executing.
When you run it: ./backup.sh
You get: "Permission denied"

What commands would you use to fix this?

```sh
aishuser@aish-ubuntu-tws:~$ touch backup.sh
aishuser@aish-ubuntu-tws:~$ echo "successful" > backup.sh 
aishuser@aish-ubuntu-tws:~$ ls -lrt
-rw-rw-r-- 1 aishuser aishuser       11 Apr 26 14:00 backup.sh
aishuser@aish-ubuntu-tws:~$ ./backup.sh
-bash: ./backup.sh: Permission denied
```

```sh
Step-1: ls -lrt 
Why: check the file permissions, user should have execute permission

Step-2: chmod u+x backup.sh
Why: provide execute permission to user

Step-3: ls -lrt
Why: verify the permission changed

Step-4: ./backup.sh
Why: run the script
```