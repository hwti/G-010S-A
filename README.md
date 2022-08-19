# G-010S-A

## Introduction
This repository is meant to gather all available information on the G-010S-A GPON SFP, including firmwares and modifications.

## Detection and power-up
For the SFP to be detected, and/or for the host to give it power, the pin 6 might need to be shorted to the ground.  
See https://rsaxvc.net/blog/2020/8/15/Nokia_G-010S-A_Pin_6_Issue.html.

## Configuration access
The default IP address is 192.168.1.10, there are two interfaces :
 - SSH : user ONTUSER, password SUGAR2A041
 - HTTP : user adminadmin, password ALC#FGU

The commands shown below are all meant to be used on the SSH command-line.

## 2.5Gbps
In addition to the standard 1Gbps SFP (SGMII), the chipset supports 2.5Gbps HSGMII.

It can be configured to auto-select 1Gbps/2.5Gbps :
```
fw_setenv sgmii_mode 5
```
The current speed can be checked with :
```
onu lanpsg 0
```
The `link_status` value shows the speed :
 - 4 => 1Gbps
 - 5 => 2.5Gbps

The number of devices which support the 2.5Gbps mode is limited.  
A SFP+ network card based on BCM57810S can be used with a patched Linux/FreeBSD driver : https://www.dslreports.com/forum/r32230041-Internet-Bypassing-the-HH3K-up-to-2-5Gbps-using-a-BCM57810S-NIC

## GPON configuration
### Connection state
```
onu ploamsg
```
The returned `curr_state` shows the usual Ox state.  
For proper operation, the state should be O5, and be stable.  
If stuck in O1, check the physical connection of the fiber.  
For other cases, your ISP might require proper values for authentication, see below.

### S/N
To check the current serial number :
```
onu gtcsng
```
To set the serial number to `ABCD012345678` :
```
ritool set MfrID ABCD
ritool set G984Serial 012345678
```

### PLOAM password (SLID)
To check the current password (the `password` field contains decimal values of ASCII characters) :
```
onu gtccg
```
The value can be changed using the web interface.

## Firmwares
All known images are generated from Lantiq OpenWRT 14.07 (7.5.3).  
The firmware are u-boot images (legacy uImage) containing the Linux kernel, followed by a squashfs root filesystem.  
Only the oldest ones have Lantiq omcid present (but not used), all use the ALU/Nokia omciMgr.

The  [firmwares directory](firmwares) contains different images :
IMAGEVERSION   | SOFTWAREVERSION | BUILDDATE     | LATEST_REV | omcid present
-------------- | --------------- | ------------- | ---------- | -------------
3FE46398AFGA95 | AFG.A95p02      | 20170328_1144 | 17850      | Y
3FE46398BFGA06 | BFG.A06p02      | 20170407_1757 | 18511      | Y
3FE46398AFGB89 | AFG.B89p04      | 20170630_0517 | 22216      | N
3FE47111AFGB89 | AFG.B89         | 20170711_1243 | 22216      | N
3FE47111BFHB32 | BFH.B32p01      | 20180207_1700 | 32678      | N
3FE46398BFIB36 | BFI.B36p08      | 20180706_0545 | 46444      | N
3FE46398BGCB22 | BGC.B22p03      | 20191226_2146 |            | N
3FE46398BGCB22 | BGC.B22         | 20210125_1451 |            | N

### Upgrade
To flash a different firmware, the first step is to determine the current running image (0 or 1) :
```
ONTUSER@SFP:~# upgradestatus
***** get current running image *****
current running image is  image0 !
...
```
Then the **other** image must be flashed, the bootloader configured to boot it, and we can reboot :
```
mtd write image.bin image1
update_env_flag 1
reboot
```
