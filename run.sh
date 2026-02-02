#!/bin/bash
cd "$(dirname "$0")"

qemu-system-riscv64 \
  -machine virt \
  -m 4G \
  -smp 4 \
  -nographic \
  -drive if=pflash,format=raw,unit=0,file=/opt/homebrew/share/qemu/edk2-riscv-code.fd,readonly=on \
  -drive if=pflash,format=raw,unit=1,file=edk2-riscv-vars.fd \
  -drive file=Fedora-Cloud-Base-Generic-42.20250911-2251ba41cdd3.riscv64.qcow2,format=qcow2,if=virtio \
  -drive file=cloud-init.iso,format=raw,if=virtio \
  -device virtio-net-device,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp::2222-:22
