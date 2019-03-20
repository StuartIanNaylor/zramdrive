# Log2Zram

Usefull for IoT / maker projects for reducing SD, Nand and Emmc block wear via log operations.
Uses Zram to minimise precious memory footprint and extremely infrequent write outs.

Log2Zam is a lower write fork https://github.com/azlux/log2ram based on transient log for Systemd here : [A transient /var/log](https://www.debian-administration.org/article/661/A_transient_/var/log)
Many thanks to Azlux for the great initial project.

Can not be used for mission critical logging applications where a system crash and log loss is unaceptable.
If the extremely unlikely event of a system crash is not a major concern then L2Z can massively reduce log block wear whilst maintaining and extremely tiny memory footprint. Further resilience can be added by the use of a watchdog routine to force stop.

_____
## Menu
1. [Install](#install)
2. [Config](#config)
3. [It is working ?](#it-is-working)
4. [Uninstall](#uninstall-)

## Install
    sudo apt-get install git rsync
    git clone https://github.com/StuartIanNaylor/log2zram
    cd log2zram
    sudo sh install.sh
    

## Customize
#### variables :
In the file `/etc/log2zram.conf` sudo nano /etc/log2zram.conf to edit:
```
# Size for the zram memory used, it defines the mem_limit for the zram device.
# The default is 20M and is basically enough for minimal applications.
# Because aplications can often vary in logging frequency this may have to be tweaked to suit application .
SIZE=20M
# COMP_ALG this is any compression algorithm listed in /proc/crypto
# lz4 is fastest with lightest load but deflate (zlib) and Zstandard (zstd) give far better compression ratios
# lzo is very close to lz4 and may with some binaries have better optimisation
# COMP_ALG=lz4 for speed or deflate for compression, lzo or zlib if optimisation or availabilty is a problem
COMP_ALG=lz4
# LOG_DISK_SIZE is the uncompressed disk size. Note zram uses about 0.1% of the size of the disk when not in use
# LOG_DISK_SIZE is expected compression ratio of alg chosen multiplied by log SIZE where 300% is an approx good level.
# lzo/lz4=2.1:1 compression ratio zlib=2.7:1 zstandard=2.9:1
# Really a guestimate of a bit bigger than compression ratio whilst minimising 0.1% mem usage of disk size
LOG_DISK_SIZE=60M
# PRUNE_LEVEL if log size is below this level then old logs will be moved to hdd.log enter as %
# Moving the old logs will restart log rotation as old logs will no longer exist in /var/log/oldlog
# In normal operation hitting 50% or above can take many hourly cycles so a higher prune level is a balance
# 55-60% is probably a good level as too high will restart logrotation and create less history  
PRUNE_LEVEL=60

# ****************** Scheduler settings for logrotate override and prune frequencies **********************
# LOGROTATE_FREQ & PRUNE_FREQ are the count in hours each operation will take place
# LOGROTATE_FREQ= Leave empty to turn off and use normal cron daily
# LOGROTATE_FREQ=12 twice daily, LOGROTATE_FREQ=6 four times daily with LOGROTATE_FREQ=1 hourly
LOGROTATE_FREQ=
# PRUNE_FREQ will check if available space % is less than PRUNE_LEVEL and if so move and clean /oldlog
# PRUNE_FREQ=12 twice daily, PRUNE_FREQ=6 four times daily with PRUNE_FREQ=1 hourly
PRUNE_FREQ=1
```

#### refresh time:
By default Log2Zram checks available log space every hour (PRUNE_FREQ=1). It them makes a comparison of the available space percentage against Prune_Level and only writes out old logs to disk when triggered (if lower) and then removes the collected old logs from zram space.
For low space considerations you can also increase the daily logrotate by setting LOGROTATE_FREQ=6 for 4 times daily if left as LOGROTATE_FREQ= then this function remains off and normal daily cron Logrotate will function

### It is working?
```
pi@raspberrypi:~/log2zram $ df "/var/log" -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/zram0       55M  2.6M   48M   6% /var/log
…
pi@raspberrypi:~/log2zram $ zramctl
NAME       ALGORITHM DISKSIZE  DATA  COMPR TOTAL STREAMS MOUNTPOINT
/dev/zram0 lz4            60M  6.7M 903.5K  1.2M       1 /var/log
```

### Testing
```
sudo /usr/local/bin/log2zram/log2zram prune
```
Checks PRUNE_LEVEL > available free space % if true will move and clean /var/log/oldlog to hdd.log
```
sudo logrotate -vf /etc/logrotate.conf
```
Force the daily logrotate with verbose output

If you get into a situation where the initial /var/log size is bigger than the initial available disk size do the following.
logrotate -vf /etc/logrotate.conf as due to the olddir directive this will move the current logs to /oldlog
sudo /usr/local/bin/log2zram/log2zram prune will prune those logs to hhd.log
If log bloat was due to some problem you may keep current /etc/log2zram.conf setting or increase the Size and corresponding Log_Disk_Size to compensate.


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
sudo sh /usr/local/bin/log2zram/uninstall.sh
```
/var/hdd.log is retained on uninstall and only removed on new install.
