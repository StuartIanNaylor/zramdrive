# Zramdrive

Usefull for IoT / maker projects for reducing SD, Nand and Emmc block wear via write operations.
Uses Zram to minimise precious memory footprint and extremely infrequent write outs.

Zramdrive is a lower write fork https://github.com/azlux/log2ram based on transient log for Systemd here : [A transient /var/log](https://www.debian-administration.org/article/661/A_transient_/var/log)
Many thanks to Azlux for the great initial project.

Can not be used for mission critical applications where a system crash and log loss is unaceptable.
If the extremely unlikely event of a system crash is not a major concern then L2Z can massively reduce block wear whilst maintaining and extremely tiny memory footprint whilst inceasing i/o perf. Further resilience can be added by the use of a watchdog routine to force stop.

_____
## Menu
1. [Install](#install)
2. [Config](#config)
3. [It is working ?](#it-is-working)
4. [Uninstall](#uninstall-)

## Install
    sudo apt-get install git
    git clone https://github.com/StuartIanNaylor/zramdrive
    cd zramdrive
    sudo sh install.sh
    

## Customize
#### variables :
In the file `/etc/log2zram.conf` sudo nano /etc/log2zram.conf to edit:
```
# Size for the zram memory used, it defines the mem_limit for the zram device.
# The default is 20M and is basically enough for minimal applications.
# Because aplications can vary in space requirements this may have to be tweaked to suit application .
SIZE=20M
# COMP_ALG this is any compression algorithm listed in /proc/crypto
# lz4 is fastest with lightest load but deflate (zlib) and Zstandard (zstd) give far better compression ratios
# lzo is very close to lz4 and may with some binaries have better optimisation
# COMP_ALG=lz4 for speed or deflate for compression, lzo or zlib if optimisation or availabilty is a problem
COMP_ALG=lz4
# DISK_SIZE is the uncompressed disk size. Note zram uses about 0.1% of the size of the disk when not in use
# DISK_SIZE is expected compression ratio of alg chosen multiplied by SIZE where 300% is an approx good level.
# lzo/lz4=2.1:1 compression ratio zlib=2.7:1 zstandard=2.9:1
# Really a guestimate of a bit bigger than compression ratio whilst minimising 0.1% mem usage of disk size
DISK_SIZE=60M
# HDD_DIR is the persistant directory that your bind will move the old directory to.
# Can be any name often placed in /var or /opt are valid locations but can be placed anywhere
HDD_DIR=/opt/moved
# ZRAM_DIR is the directory that will firstly moved to HDD_DIR then mounted as Zram with data copied
# ZRAM_DIR is the live zram drive of the directory you wish to use
ZRAM_DIR=/var/backups
```



### It is working?
```
pi@raspberrypi:~/zramdrive $ zramctl
NAME       ALGORITHM DISKSIZE  DATA  COMPR TOTAL STREAMS MOUNTPOINT
/dev/zram0 lz4            15M    5M 348.4K  772K       1 /var/log
/dev/zram1 lz4         650.2M    4K    64B    4K       1 [SWAP]
/dev/zram2 lz4            60M  4.7M 295.5K  568K       1 /var/backups

```



| Compressor name	     | Ratio	| Compression | Decompress. |
|------------------------|----------|-------------|-------------|
|zstd 1.3.4 -1	         | 2.877	| 470 MB/s	  | 1380 MB/s   |
|zlib 1.2.11 -1	         | 2.743    | 110 MB/s    | 400 MB/s    |
|brotli 1.0.2 -0	     | 2.701	| 410 MB/s	  | 430 MB/s    |
|quicklz 1.5.0 -1	     | 2.238	| 550 MB/s	  | 710 MB/s    |
|lzo1x 2.09 -1	         | 2.108	| 650 MB/s	  | 830 MB/s    |
|lz4 1.8.1	             | 2.101    | 750 MB/s    | 3700 MB/s   |
|snappy 1.1.4	         | 2.091	| 530 MB/s	  | 1800 MB/s   |
|lzf 3.6 -1	             | 2.077	| 400 MB/s	  | 860 MB/s    |


## Uninstall
```
sudo sh /usr/local/bin/zramdrive/uninstall.sh
```
$HDD_DIR is retained on uninstall and only removed on new install.
