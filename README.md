# Note

# Struttura directory

```bash
.
├── appdev
├── artifact
├── bootloader
├── buildroot
├── debugging
├── rootfs
├── script
├── tinysystem
└── toolchain
```

* `artifact` contiene tutti gli artefatti prodotti da Yocto
* `rootfs` contiene il rootfs che viene usato via nfs
* `script` contiene alcuni script come `qemu-tap-script.sh`

# Comandi da eseguire

```bash
$ cd /home/dooraim/embedded-linux-qemu-labs
$ sudo ./script/qemu-tap-script.sh
$ sudo exportfs -r
$ sudo qemu-system-arm -M vexpress-a9 -m 256M -nographic -kernel artifact/artifact-qemu-debug/images/qemuarma9/zImage -dtb artifact/artifact-qemu-debug/images/qemuarma9/vexpress-v2p-ca9.dtb -append "console=ttyAMA0 root=/dev/nfs ip=192.168.64.18 nfsroot=192.168.64.16:/home/dooraim/embedded-linux-qemu-labs/rootfs,nfsvers=3,tcp rw" -net tap,ifname=tap0,script=no -net nic
```

Indirizzo ip del bridge è `192.168.64.17`
Indirizzo ip del tap0 è `192.168.64.18`

# Bridge

Applico bridge sull'interfaccia `enp0s2`

```bash
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 96:32:bc:d7:0b:46 brd ff:ff:ff:ff:ff:ff
    inet 192.168.128.5/24 metric 100 brd 192.168.128.255 scope global dynamic enp0s1
       valid_lft 85339sec preferred_lft 85339sec
    inet6 fe80::9432:bcff:fed7:b46/64 scope link 
       valid_lft forever preferred_lft forever
3: enp0s2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master br0 state UP group default qlen 1000
    link/ether 6a:28:5e:a1:74:59 brd ff:ff:ff:ff:ff:ff
    inet 192.168.64.16/24 metric 100 brd 192.168.64.255 scope global dynamic enp0s2
       valid_lft 85339sec preferred_lft 85339sec
    inet6 fd2e:a786:474b:8d47:6828:5eff:fea1:7459/64 scope global dynamic mngtmpaddr noprefixroute 
       valid_lft 2591314sec preferred_lft 604114sec
    inet6 fe80::6828:5eff:fea1:7459/64 scope link 
       valid_lft forever preferred_lft forever
4: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether fa:fc:3d:a7:3f:95 brd ff:ff:ff:ff:ff:ff
    inet 192.168.128.6/24 metric 100 brd 192.168.128.255 scope global dynamic enp0s3
       valid_lft 85339sec preferred_lft 85339sec
    inet6 fe80::f8fc:3dff:fea7:3f95/64 scope link 
       valid_lft forever preferred_lft forever
5: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:e1:5e:fe:c6 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
6: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 7a:09:fa:df:67:b6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.64.17/24 brd 192.168.64.255 scope global dynamic br0
       valid_lft 85743sec preferred_lft 85743sec
    inet6 fd2e:a786:474b:8d47:a3d5:bb61:7f61:b414/64 scope global temporary dynamic 
       valid_lft 604130sec preferred_lft 85704sec
    inet6 fd2e:a786:474b:8d47:7809:faff:fedf:67b6/64 scope global dynamic mngtmpaddr 
       valid_lft 2591941sec preferred_lft 604741sec
    inet6 fe80::7809:faff:fedf:67b6/64 scope link 
       valid_lft forever preferred_lft forever
7: tap0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel master br0 state DOWN group default qlen 1000
    link/ether b2:ec:4f:7d:c8:fc brd ff:ff:ff:ff:ff:ff
    inet6 fe80::b0ec:4fff:fe7d:c8fc/64 scope link 
       valid_lft forever preferred_lft forever
```

# Toolchain

```bash
$ export PATH="$PATH:$HOME/x-tools/arm-cortexa9_neon-linux-uclibcgnueabihf/bin"
```

Copiare poi la libreria nel rootfs.

```bash
$ sudo cp ~/x-tools/arm-cortexa9_neon-linux-uclibcgnueabihf/arm-cortexa9_neon-linux-uclibcgnueabihf/sysroot/lib/ld-uClibc.so.0 rootfs/lib/.
$ sudo cp ~/x-tools/arm-cortexa9_neon-linux-uclibcgnueabihf/arm-cortexa9_neon-linux-uclibcgnueabihf/sysroot/lib/ld-uClibc.so.0 rootfs/usr/lib/.
$ sudo cp ~/x-tools/arm-cortexa9_neon-linux-uclibcgnueabihf/arm-cortexa9_neon-linux-uclibcgnueabihf/sysroot/lib/libc.so.0  rootfs/lib/.
$ sudo cp ~/x-tools/arm-cortexa9_neon-linux-uclibcgnueabihf/arm-cortexa9_neon-linux-uclibcgnueabihf/sysroot/lib/libc.so.0  rootfs/usr/lib/.
```

# Compilare per `gdb` - `gdbserver`

Compilare il programma che si vuole debuggare nel modo seguente.

```bash
$ arm-cortexa9_neon-linux-uclibcgnueabihf-gcc sum_script.c -o sum_script -lm -g
```

Copiare `sum_script` sul target.

Se lo si esegue si ha il seguente log.

```bash
root@qemuarma9:~# ./sum_script 
sum = 55
```

# Esecuzione per `gdb` - `gdbserver` (script in C)

Sul target eseguire il comando seguente:

```bash
root@qemuarma9:~# gdbserver :10000 ./sum_script  
Process ./sum_script created; pid = 293
Listening on port 10000
```

Sul host eseguire il comando seguente:

```bash
$ arm-cortexa9_neon-linux-uclibcgnueabihf-gdb sum_script
GNU gdb (crosstool-NG 1.25.0.95_7622b49) 12.1
Copyright (C) 2022 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "--host=aarch64-build_unknown-linux-gnu --target=arm-cortexa9_neon-linux-uclibcgnueabihf".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<https://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from sum_script...
(gdb) target remote 192.168.64.18:10000
Remote debugging using 192.168.64.18:10000
Reading symbols from /home/dooraim/x-tools/arm-cortexa9_neon-linux-uclibcgnueabihf/arm-cortexa9_neon-linux-uclibcgnueabihf/sysroot/lib/ld-uClibc.so.0...
(No debugging symbols found in /home/dooraim/x-tools/arm-cortexa9_neon-linux-uclibcgnueabihf/arm-cortexa9_neon-linux-uclibcgnueabihf/sysroot/lib/ld-uClibc.so.0)
0xb6fe0138 in _start ()
   from /home/dooraim/x-tools/arm-cortexa9_neon-linux-uclibcgnueabihf/arm-cortexa9_neon-linux-uclibcgnueabihf/sysroot/lib/ld-uClibc.so.0
(gdb) 
```
