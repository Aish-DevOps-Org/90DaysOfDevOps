#### Linux Volume Management (LVM)

##### Task

1. Created 2 disk vol

vol1 = 4GB

vol2 = 8GB



2\. Check current storage

```

root@aish-ubuntu-tws:\~# lsblk

NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS

sda       8:0    0    4G  0 disk

sdb       8:16   0    8G  0 disk

sdc       8:32   0   30G  0 disk

├─sdc1    8:33   0   29G  0 part /

├─sdc14   8:46   0    4M  0 part

├─sdc15   8:47   0  106M  0 part /boot/efi

└─sdc16 259:0    0  913M  0 part /boot



root@aish-ubuntu-tws:\~# df -h

Filesystem      Size  Used Avail Use% Mounted on

/dev/root        29G  3.4G   25G  12% /

tmpfs           1.9G     0  1.9G   0% /dev/shm

tmpfs           774M  996K  773M   1% /run

tmpfs           5.0M     0  5.0M   0% /run/lock

efivarfs        128K   38K   86K  31% /sys/firmware/efi/efivars

/dev/sdc16      881M  117M  703M  15% /boot

/dev/sdc15      105M  6.2M   99M   6% /boot/efi

tmpfs           387M   12K  387M   1% /run/user/1000



root@aish-ubuntu-tws:\~# pvs



root@aish-ubuntu-tws:\~# lvs



root@aish-ubuntu-tws:\~# vgs

```



3\. Create Physical Volume

```

root@aish-ubuntu-tws:\~# pvcreate /dev/sda

&#x20; Physical volume "/dev/sda" successfully created.

root@aish-ubuntu-tws:\~# pvcreate /dev/sdb

&#x20; Physical volume "/dev/sdb" successfully created.

root@aish-ubuntu-tws:\~# pvs

&#x20; PV         VG Fmt  Attr PSize PFree

&#x20; /dev/sda      lvm2 ---  4.00g 4.00g

&#x20; /dev/sdb      lvm2 ---  8.00g 8.00g

```



4\. Create volume group

```

root@aish-ubuntu-tws:\~# vgcreate aish\_vg /dev/sda /dev/sdb

&#x20; Volume group "aish\_vg" successfully created

root@aish-ubuntu-tws:\~# vgs

&#x20; VG      #PV #LV #SN Attr   VSize  VFree

&#x20; aish\_vg   2   0   0 wz--n- 11.99g 11.99g

```



5\. Create logical volume

```

root@aish-ubuntu-tws:/dev# lvcreate -L 5G -n aishlv aish\_vg

WARNING: ext4 signature detected on /dev/aish\_vg/aishlv at offset 1080. Wipe it? \[y/n]: y

&#x20; Wiping ext4 signature on /dev/aish\_vg/aishlv.

&#x20; Logical volume "aishlv" created.



root@aish-ubuntu-tws:/dev# lvs

&#x20; LV     VG      Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert

&#x20; aishlv aish\_vg -wi-a----- 5.00g

```



```

root@aish-ubuntu-tws:/dev# lsblk

NAME             MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS

sda                8:0    0    4G  0 disk

**sdb                8:16   0    8G  0 disk**

**└─aish\_vg-aishlv 252:0    0    5G  0 lvm**

sdc                8:32   0   30G  0 disk

├─sdc1             8:33   0   29G  0 part /

├─sdc14            8:46   0    4M  0 part

├─sdc15            8:47   0  106M  0 part /boot/efi

└─sdc16          259:0    0  913M  0 part /boot

```



6\. Format and mount

```

root@aish-ubuntu-tws:\~# mkfs.ext4 /dev/aish\_vg/aishlv

mke2fs 1.47.0 (5-Feb-2023)

Discarding device blocks: done

Creating filesystem with 1310720 4k blocks and 327680 inodes

Filesystem UUID: 70b4d896-4382-41ec-b826-5b57adf1fcd1

Superblock backups stored on blocks:

&#x20;       32768, 98304, 163840, 229376, 294912, 819200, 884736



Allocating group tables: done

Writing inode tables: done

Creating journal (16384 blocks): done

Writing superblocks and filesystem accounting information: done



root@aish-ubuntu-tws:\~# mkdir -p /mnt/app-data

root@aish-ubuntu-tws:\~# mount /dev/aish\_vg/aishlv /mnt/app-data/

root@aish-ubuntu-tws:\~# df -h

Filesystem                  Size  Used Avail Use% Mounted on

/dev/root                    29G  3.4G   25G  12% /

tmpfs                       1.9G     0  1.9G   0% /dev/shm

tmpfs                       774M  996K  773M   1% /run

tmpfs                       5.0M     0  5.0M   0% /run/lock

efivarfs                    128K   38K   86K  31% /sys/firmware/efi/efivars

/dev/sdc16                  881M  117M  703M  15% /boot

/dev/sdc15                  105M  6.2M   99M   6% /boot/efi

tmpfs                       387M   12K  387M   1% /run/user/1000

/dev/mapper/aish\_vg-aishlv  4.9G   24K  4.6G   1% /mnt/app-data



root@aish-ubuntu-tws:\~# lsblk

NAME             MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS

sda                8:0    0    4G  0 disk

sdb                8:16   0    8G  0 disk

└─aish\_vg-aishlv 252:0    0    5G  0 lvm  /mnt/app-data

sdc                8:32   0   30G  0 disk

├─sdc1             8:33   0   29G  0 part /

├─sdc14            8:46   0    4M  0 part

├─sdc15            8:47   0  106M  0 part /boot/efi

└─sdc16          259:0    0  913M  0 part /boot

```



7\. Extend the volume

```

root@aish-ubuntu-tws:\~# lvextend -L +4G /dev/aish\_vg/aishlv

&#x20; Size of logical volume aish\_vg/aishlv changed from 5.00 GiB (1280 extents) to 9.00 GiB (2304 extents).

&#x20; Logical volume aish\_vg/aishlv successfully resized.



aishuser@aish-ubuntu-tws:\~$ lsblk

NAME             MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS

sda                8:0    0    4G  0 disk

└─aish\_vg-aishlv 252:0    0    9G  0 lvm  /mnt/app-data

sdb                8:16   0    8G  0 disk

└─aish\_vg-aishlv 252:0    0    9G  0 lvm  /mnt/app-data

sdc                8:32   0   30G  0 disk

├─sdc1             8:33   0   29G  0 part /

├─sdc14            8:46   0    4M  0 part

├─sdc15            8:47   0  106M  0 part /boot/efi

└─sdc16          259:0    0  913M  0 part /boot



root@aish-ubuntu-tws:\~# df -h /mnt/app-data

Filesystem                  Size  Used Avail Use% Mounted on

/dev/mapper/aish\_vg-aishlv  4.9G   24K  4.6G   1% /mnt/app-data



root@aish-ubuntu-tws:\~# resize2fs /dev/aish\_vg/aishlv

resize2fs 1.47.0 (5-Feb-2023)

Filesystem at /dev/aish\_vg/aishlv is mounted on /mnt/app-data; on-line resizing required

old\_desc\_blocks = 1, new\_desc\_blocks = 2

The filesystem on /dev/aish\_vg/aishlv is now 2359296 (4k) blocks long.



root@aish-ubuntu-tws:\~# df -h /mnt/app-data

Filesystem                  Size  Used Avail Use% Mounted on

/dev/mapper/aish\_vg-aishlv  8.8G   24K  8.4G   1% /mnt/app-data



```



Learning-

* How to create physical, logical volume and vol group.
* How to extend the LV
* How to mount the vol to a disk for usage
* How to see details of these volumes





