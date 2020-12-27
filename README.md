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
