# G-010S-A

## Introduction
This repository is meant to gather all available information on the G-010S-A GPON SFP, including firmwares and modifications.

## Compatibility and Known Issues
<a id="compatibility"></a>

Depending on the SFP host there may be various compatibility issues and behavior
changes with the SFP module.

* **Pin 6 issue**: With some hosts the module is not properly recognized as
  "present" due to pin 6 on the module not being fully grounded.
* **Requires fiber**: The host will only connect to the module if a fiber signal
  is detected. Without a fiber the module signals "LOS" which the host
  interprets as "do not communicate".
* **DyingGasp Issue**: If the module firmware enables *dying gasp* then the host
  will cause the module to reboot before being fully active.

This table lists the known behaviors:

| SFP Host                  | PIN 6 Issue         | Requires Fiber | DyingGasp Issue
|---------------------------|---------------------|----------------|-----------------
| BCM57810S                 | Always              | N              | ?
| CSR305                    | When serial enabled | Y              | ?
| 10Gtek WG-33-1GX1GT-SFP   | Never               | N              | N
| Netgear GS752TPV2         | Never               | N              | Y
| MC220L                    | Never               | ?              | ?
| SolidRun Clearfog         | When serial enabled | Y              | Y

### Fixing the Pin 6 Issue

[This page](https://rsaxvc.net/blog/2020/8/15/Nokia_G-010S-A_Pin_6_Issue.html)
describes a fix for the pin 6 issue involving shortening a pin.

WARNING: Shorting the pin on the module may make the serial console
non-functional, preventing unbricking the SFP via serial console.

### Fixing the *Dying Gasp* Issue

The issue is caused by eeprom 1 having a value of *0x02* at index *0xfc*. This
is set in ```/etc/init.d/sfp_eeprom.sh``` with ```sfp_i2c -i 0x1fc -w
0x02```. One possibl fix is to set the value to *0x00* instead.

See ```extract.sh``` and ```patch.sh``` in this repository for information about
creating a patched firmware.

## Configuration access
The default IP address is 192.168.1.10, there are two interfaces :
 - SSH : user ONTUSER, password SUGAR2A041
 - HTTP : user adminadmin, password ALC#FGU

Modern SSH configs might not be able to negotiate a connection with the legacy ciphers by default. If that is the case, run the following usage:

```bash
$ ssh -o KexAlgorithms=+diffie-hellman-group1-sha1 -o HostKeyAlgorithms=+ssh-rsa ONTUSER@192.168.1.10
```

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
Only the oldest ones have Lantiq omcid present (but not used), all 

The  [firmwares directory](firmwares) contains different images :

* **OMCID**: This firmware have Lantiq omcid binary present (but not used). All
  firmwares use the ALU/Nokia omciMgr.
* **Op req**: With this firmware you need to set the operator to 0000
  to change the serial number using ```ritool set OperatorID 0000```.
* **DyingGasp**: This firmware will enable dying gasp by default. This can cause
  the module to go into a boot cycle depending on the host behavior.

IMAGEVERSION   | SOFTWAREVERSION | BUILDDATE     | LATEST_REV | OMCID | Op Req | DyingGasp
-------------- | --------------- | ------------- | ---------- | ------|--------|-----------
3FE46398AFGA95 | AFG.A95p02      | 20170328_1144 | 17850      | Y     | N?     | N
3FE46398BFGA06 | BFG.A06p02      | 20170407_1757 | 18511      | Y     | N?     | N
3FE46398AFGB89 | AFG.B89p04      | 20170630_0517 | 22216      | N     | N?     | N
3FE47111AFGB89 | AFG.B89         | 20170711_1243 | 22216      | N     | N?     | N
3FE47111BFHB32 | BFH.B32p01      | 20180207_1700 | 32678      | N     | N      | N
3FE46398BFGB18 | BFG.B18p01      | 20180522_1434 | 22148      | N     | N      | Y
3FE46398BFIB36 | BFI.B36p08      | 20180706_0545 | 46444      | N     | Y      | Y
3FE46398BGCB22 | BGC.B22p03      | 20191226_2146 |            | N     | Y      | Y
3FE46398BGCB22 | BGC.B22         | 20210125_1451 |            | N     | Y      | Y

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
update_env_flag next_active 1
reboot
```

If the boot is successful the module will continue to boot from the new firmware
by setting ```commit``` to the ```next_active``` image. If the initial boot
fails for some reason the module should revert to the old firmware and reset
```next_active```.
