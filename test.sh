touch /tmp/disk.qcow2
docker run -it --rm \
  -v /tmp/disk.qcow2:/tmp/disk.qcow2 \
  -v $PWD:/build \
  -w /build \
  -e QEMU_HDA=/tmp/disk.qcow2 \
  -e QEMU_HDA_SIZE=4G \
  -e QEMU_CPU=4 \
  -e QEMU_RAM=4096 \
  -e QEMU_BOOT='n' \
  tianon/qemu /bin/bash
