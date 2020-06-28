#!/bin/bash

# Run with:
# docker run --cap-add=NET_ADMIN -v $PWD:/build -w /build -v /dev/net/tun:/dev/net/tun -v ~/workspace/deployments/metal/pxe/configs/qemu-test/boot-test.pem:/boot-test.pem -v ~/workspace/deployments/metal/pxe:/pxe -it ljfranklin/netboot-buildroot

set -eu

qemu_pid=""
http_pid=""
pixiecore_pid=""
cleanup() {
  if [ -n "${qemu_pid}" ]; then
    kill "${qemu_pid}"
  fi
  if [ -n "${http_pid}" ]; then
    kill "${http_pid}"
  fi
  if [ -n "${pixiecore_pid}" ]; then
    kill "${pixiecore_pid}"
  fi
}
trap 'cleanup' EXIT

pushd /pxe > /dev/null
  python3 -m http.server 8000 &
  http_pid="$!"
  # TODO: compile this
  ./pixiecore api http://localhost:8000 --debug --dhcp-no-bind &
  pixiecore_pid="$!"
popd > /dev/null

cp /boot-test.pem /tmp/boot-test.pem
chmod 600 /tmp/boot-test.pem

ip link add name br0 type bridge
ip addr add 172.20.0.1/16 dev br0
ip link set br0 up
dnsmasq --interface=br0 --bind-interfaces \
  --dhcp-range=172.20.0.2,172.20.255.254 --dhcp-host=52:54:00:12:34:56,172.20.0.10 \
  --server=8.8.8.8

[[ ! -d /etc/qemu ]] && mkdir /etc/qemu
echo allow br0 > /etc/qemu/bridge.conf

iptables -t nat -A POSTROUTING -o wlp58s0 -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i tap0 -o wlp58s0 -j ACCEPT

qemu-img create /tmp/disk.img 4G

qemu-system-x86_64 -smp "$(nproc)" -m 4096 \
  -net nic,model=virtio -net bridge,br=br0 \
  -hda /tmp/disk.img &
qemu_pid="$!"

runtime="15 minute"
endtime="$(date -ud "$runtime" +%s)"

ssh_result=-1
while [[ "$(date -u +%s)" -le "${endtime}" ]]; do
  set +e
  ssh -i /tmp/boot-test.pem \
    -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    boot-test@172.20.0.10 true
  ssh_result="$?"
  set -e

  echo "${ssh_result}"
  if [ "${ssh_result}" -eq 0 ]; then
    break
  fi
  sleep 10
done

if [ "${ssh_result}" -eq 0 ]; then
  echo "Success!"
  exit 0
fi

echo "Failure! Timed out waiting for SSH to be available"
exit 1
