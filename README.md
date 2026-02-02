# RISC-V Playground

QEMU-based RISC-V development environment running Fedora Cloud on the `virt` machine with EDK2 UEFI firmware.

## Quick Start

```bash
# Install dependencies (macOS)
brew install qemu cdrtools

# Download VM image and setup environment
./setup.sh

# Start the VM
./run.sh
```

## VM Details

- **Architecture**: RISC-V 64-bit
- **Machine**: QEMU virt
- **Firmware**: EDK2 UEFI
- **OS**: Fedora Cloud 42
- **Memory**: 4GB
- **CPUs**: 4 cores
- **Network**: User-mode networking with SSH forwarded to host port 2222

## Login

After first boot (cloud-init takes ~1-2 min):

```bash
# Console login
username: fedora
password: fedora

# SSH from host
ssh -p 2222 fedora@localhost
```

## Files

- `run.sh` — Start the VM
- `setup.sh` — Download image and setup environment
- `cloud-init/` — Cloud-init configuration (user setup)
- `riscv-boot-deepdive.txt` — Notes on RISC-V boot process
- `riscv-sbi-doc/` — RISC-V SBI specification docs

## Exit QEMU

Press `Ctrl-A` then `x`
