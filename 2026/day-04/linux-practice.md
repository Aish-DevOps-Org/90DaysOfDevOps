#### **Process checks**

1. ###### **ps** - snapshot of running processes

aishuser@aish-ubuntu-tws:~$ ps
    PID TTY          TIME CMD
   3510 pts/0    00:00:00 bash
   3548 pts/0    00:00:00 systemctl
   3549 pts/0    00:00:00 pager
   3555 pts/0    00:00:00 systemctl
   3556 pts/0    00:00:00 pager
   3585 pts/0    00:00:00 systemctl
   3586 pts/0    00:00:00 pager
   3614 pts/0    00:00:00 top
   3656 pts/0    00:00:00 ps


2. ###### **top** - real time system stats

aishuser@aish-ubuntu-tws:~$ top
top - 11:06:51 up  1:04,  1 user,  load average: 0.00, 0.00, 0.00
Tasks: 126 total,   1 running, 119 sleeping,   6 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :   3866.4 total,   2053.1 free,    819.2 used,   1274.1 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used.   3047.2 avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
    735 root      20   0 1040580 150880  66988 S   0.3   3.8   0:08.63 wdavdaemon
   1118 root      20   0  943776  89668  60268 S   0.3   2.3   0:08.79 wdavdaemon
   3614 aishuser  20   0   12400   5924   3672 R   0.3   0.1   0:00.03 top
      1 root      20   0   22916  14404   9808 S   0.0   0.4   0:03.25 systemd
      2 root      20   0       0      0      0 S   0.0   0.0   0:00.00 kthreadd
      3 root      20   0       0      0      0 S   0.0   0.0   0:00.00 pool_workque+
      4 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/R-rc+
      5 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker/R-sy+


#### **Service checks**

1. ###### **Systemctl** - check status of a service

aishuser@aish-ubuntu-tws:~$ systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: enabled)
     Active: active (running) since Thu 2026-03-26 10:51:31 UTC; 16s ago
       Docs: man:nginx(8)
    Process: 3283 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 3284 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 3314 (nginx)
      Tasks: 3 (limit: 4597)
     Memory: 2.4M (peak: 5.0M)
        CPU: 24ms
     CGroup: /system.slice/nginx.service
             ├─3314 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             ├─3317 "nginx: worker process"
             └─3318 "nginx: worker process"

Mar 26 10:51:31 aish-ubuntu-tws systemd[1]: Starting nginx.service - A high performance web server and a reverse proxy server...
Mar 26 10:51:31 aish-ubuntu-tws systemd[1]: Started nginx.service - A high performance web server and a reverse proxy server.

2. ###### **systemctl list-units** - Lists all running services

aishuser@aish-ubuntu-tws:~$ systemctl list-units --type=service
  UNIT                                                  LOAD   ACTIVE SUB     DESCRIPTION
  apparmor.service                                      loaded active exited  Load AppArmor profiles
  apport.service                                        loaded active exited  automatic crash report generation
  blk-availability.service                              loaded active exited  Availability of block devices
  chrony.service                                        loaded active running chrony, an NTP client/server
  cloud-config.service                                  loaded active exited  Cloud-init: Config Stage
  cloud-final.service                                   loaded active exited  Cloud-init: Final Stage
  cloud-init-local.service                              loaded active exited  Cloud-init: Local Stage (pre-network)
  cloud-init.service                                    loaded active exited  Cloud-init: Network Stage
  console-setup.service                                 loaded active exited  Set console font and keymap
  cron.service                                          loaded active running Regular background program processing daemon
  dbus.service                                          loaded active running D-Bus System Message Bus
  finalrd.service                                       loaded active exited  Create final runtime dir for shutdown pivot root
  fwupd.service                                         loaded active running Firmware update daemon



#### **Log checks**

1. ###### **journalctl** - view logs of service

aishuser@aish-ubuntu-tws:~$ sudo systemctl restart nginx
aishuser@aish-ubuntu-tws:~$ journalctl -u nginx
Mar 26 10:51:31 aish-ubuntu-tws systemd[1]: Starting nginx.service - A high performa>
Mar 26 10:51:31 aish-ubuntu-tws systemd[1]: Started nginx.service - A high performan>
Mar 26 11:12:41 aish-ubuntu-tws systemd[1]: Stopping nginx.service - A high performa>
Mar 26 11:12:41 aish-ubuntu-tws systemd[1]: nginx.service: Deactivated successfully.
Mar 26 11:12:41 aish-ubuntu-tws systemd[1]: Stopped nginx.service - A high performan>
Mar 26 11:12:41 aish-ubuntu-tws systemd[1]: Starting nginx.service - A high performa>
Mar 26 11:12:41 aish-ubuntu-tws systemd[1]: Started nginx.service - A high performan>
 

2. ###### **tail** - Print  the  last  10 lines of each FILE to standard output. Monitor logs live

aishuser@aish-ubuntu-tws:~$ tail -f /var/log/syslog
2026-03-26T11:07:38.516108+00:00 aish-ubuntu-tws systemd[1]: collect-logs.scope: Deactivated successfully.
2026-03-26T11:07:38.521274+00:00 aish-ubuntu-tws python3[959]: 2026-03-26T11:07:38.521219Z INFO CollectLogsHandler ExtHandler Successfully uploaded logs.
2026-03-26T11:10:26.216714+00:00 aish-ubuntu-tws systemd[1]: Starting sysstat-collect.service - system activity accounting tool...
2026-03-26T11:10:26.223733+00:00 aish-ubuntu-tws systemd[1]: sysstat-collect.service: Deactivated successfully.
2026-03-26T11:10:26.224035+00:00 aish-ubuntu-tws systemd[1]: Finished sysstat-collect.service - system activity accounting tool.
2026-03-26T11:12:41.640523+00:00 aish-ubuntu-tws systemd[1]: Stopping nginx.service - A high performance web server and a reverse proxy server...
2026-03-26T11:12:41.664653+00:00 aish-ubuntu-tws systemd[1]: nginx.service: Deactivated successfully.
2026-03-26T11:12:41.664944+00:00 aish-ubuntu-tws systemd[1]: Stopped nginx.service - A high performance web server and a reverse proxy server.
2026-03-26T11:12:41.670407+00:00 aish-ubuntu-tws systemd[1]: Starting nginx.service - A high performance web server and a reverse proxy server...
2026-03-26T11:12:41.687927+00:00 aish-ubuntu-tws systemd[1]: Started nginx.service - A high performance web server and a reverse proxy server.


3. ##### **less** - View and scroll logs up and down and exit. Does not print on the terminal.

2026-03-25T11:29:57.692787+00:00 aish-ubuntu-tws systemd-fsck[151]: cloudimg-rootfs: clean, 79403/327680 files, 452329/655099 blocks
2026-03-25T11:29:57.693851+00:00 aish-ubuntu-tws systemd-modules-load[149]: Inserted module 'msr'
2026-03-25T11:29:57.693864+00:00 aish-ubuntu-tws systemd[1]: Mounted dev-hugepages.mount - Huge Pages File System.
2026-03-25T11:29:57.693869+00:00 aish-ubuntu-tws systemd[1]: Mounted dev-mqueue.mount - POSIX Message Queue File System.
2026-03-25T11:29:57.693874+00:00 aish-ubuntu-tws systemd[1]: Mounted sys-kernel-debug.mount - Kernel Debug File System.
2026-03-25T11:29:57.693879+00:00 aish-ubuntu-tws systemd[1]: Mounted sys-kernel-tracing.mount - Kernel Trace File System.
2026-03-25T11:29:57.693884+00:00 aish-ubuntu-tws systemd[1]: Finished keyboard-setup.service - Set the console keyboard layout.
2026-03-25T11:29:57.693889+00:00 aish-ubuntu-tws systemd[1]: Finished kmod-static-nodes.service - Create List of Static Device Nodes.








