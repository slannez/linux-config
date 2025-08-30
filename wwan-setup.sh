#!/bin/bash

lspci | grep Wireless
ls /dev | grep wwan

ROOT="/sys/bus/pci/devices/0000:00:1d.7" 
PIDID="/sys/bus/pci/devices/0000:03:00.0" 
PIDID2="/sys/bus/pci/devices/0000:00:14.3" 


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

