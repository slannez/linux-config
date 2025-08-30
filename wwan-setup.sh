#!/bin/bash
#
# License: Public domain
#
#
# This script can be used to configure the foxconn-dw5930e
# as a systemd service. Note the modem seems to go on deep
# sleep after a while, so this script should be run as soon
# as possible.
#
# Tested on: 6.15.2-9-MANJARO
# lspci -v:
# 00:00.0 Host bridge: Intel Corporation Coffee Lake HOST and DRAM Controller (rev 0c)
#	DeviceName: Onboard - Other
#	Subsystem: Dell Device 093d
#	Flags: bus master, fast devsel, latency 0
#	Capabilities: [e0] Vendor Specific Information: Intel Capabilities v1
#		CapA: Peg60Dis- Peg12Dis+ Peg11Dis+ Peg10Dis+ PeLWUDis+ DmiWidth=x4
#		      EccDis+ ForceEccEn- VTdDis- DmiG2Dis+ PegG2Dis+ DDRMaxSize=Unlimited
#		      1NDis- CDDis- DDPCDis+ X2APICEn+ PDCDis- IGDis- CDID=0 CRID=12
#		      DDROCCAP- OCEn- DDRWrtVrefEn- DDR3LEn+
#		CapB: ImguDis+ OCbySSKUCap- OCbySSKUEn- SMTCap+ CacheSzCap 0x2
#		      SoftBinCap- DDR3MaxFreqWithRef100=Disabled PegG3Dis+
#		      PkgTyp- AddGfxEn- AddGfxCap- PegX16Dis+ DmiG3Dis+ GmmDis-
#		      DDR3MaxFreq=2932MHz LPDDR3En+
#		CapC: PegG4Dis- DDR4MaxFreq=Unlimited LPDDREn- LPDDR4MaxFreq=0MHz LPDDR4En-
#		      QClkGvDis+ SgxDis- BClkOC=Disabled IddDis- Pipe3Dis- Gear1MaxFreq=Unlimited
#	Kernel driver in use: skl_uncore
#

lspci | grep Wireless
ls /dev | grep wwan

ROOT="/sys/bus/pci/devices/0000:00:1d.7" 
PIDID="/sys/bus/pci/devices/0000:03:00.0" 
PIDID2="/sys/bus/pci/devices/0000:00:14.3" 

# This function attempts
reset() {
  rmmod mhi-pci-generic
  rmmod mhi_wwan_mbim
  rmmod mhi_wwan_ctrl
  rmmod wwan

  systemctl stop ModemManager
  modprobe mhi-pci-generic
  modprobe mhi_wwan_ctrl
}

[ -e $PIDID/remove ] && echo 1 > $PIDID/remove
echo 1 > /sys/bus/pci/rescan
sleep 1
echo 0 > $PIDID/d3cold_allowed
wait

VENDER=$(cat $PIDID/vendor)
DEVICE=$(cat $PIDID/device)

echo -n "Device ($VENDER:$DEVICE) is enabled: "
cat "$PIDID/enable"

# FCC unlock procedure
sleep 1
/etc/ModemManager/fcc-unlock.d/105b wwan0mbim0 wwan0mbim0

start_service() {
  # Start modem service now
  systemctl start ModemManager
  sleep 5

  # List modems
  mmcli -L
  sleep 5

  # Enable modem
  mmcli -m 0 --enable

  # Now connect
  mmcli -m 0 --simple-connect="apn=orange"
  sleep 10

  # Very likely throttling...
  iperf -c speedtest.serverius.net
}

