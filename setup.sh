#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "==> RISC-V Playground Setup"
echo ""

# --- Check for QEMU ---
if ! command -v qemu-system-riscv64 &>/dev/null; then
  echo "ERROR: qemu-system-riscv64 not found."
  echo ""
  echo "Install QEMU:"
  if [[ "$(uname)" == "Darwin" ]]; then
    echo "  brew install qemu"
  else
    echo "  sudo apt-get install qemu-system-misc  # Debian/Ubuntu"
    echo "  sudo dnf install qemu-system-riscv     # Fedora"
  fi
  exit 1
fi

# --- Download Fedora Cloud RISC-V image ---
QCOW_FILE="Fedora-Cloud-Base-Generic-42.20250911-2251ba41cdd3.riscv64.qcow2"
QCOW_URL="https://dl.fedoraproject.org/pub/fedora-secondary/releases/42/Cloud/riscv64/images/${QCOW_FILE}"

if [[ -f "$QCOW_FILE" ]]; then
  echo "==> Found existing ${QCOW_FILE}"
else
  echo "==> Downloading Fedora Cloud RISC-V image (~745MB)..."
  echo "    URL: ${QCOW_URL}"
  if command -v curl &>/dev/null; then
    curl -L -O "$QCOW_URL"
  elif command -v wget &>/dev/null; then
    wget "$QCOW_URL"
  else
    echo "ERROR: Neither curl nor wget found. Please install one of them."
    exit 1
  fi
  echo "    Download complete: ${QCOW_FILE}"
fi

# --- Create EDK2 UEFI vars file ---
VARS_FILE="edk2-riscv-vars.fd"
if [[ -f "$VARS_FILE" ]]; then
  echo "==> Found existing ${VARS_FILE}"
else
  echo "==> Creating EDK2 UEFI vars file..."

  # Find EDK2 code file
  EDK2_CODE=""
  if [[ -f "/opt/homebrew/share/qemu/edk2-riscv-code.fd" ]]; then
    EDK2_CODE="/opt/homebrew/share/qemu/edk2-riscv-code.fd"
  elif [[ -f "/usr/share/qemu/edk2-riscv-code.fd" ]]; then
    EDK2_CODE="/usr/share/qemu/edk2-riscv-code.fd"
  elif [[ -f "/usr/share/edk2/riscv/RISCV_VIRT_CODE.fd" ]]; then
    EDK2_CODE="/usr/share/edk2/riscv/RISCV_VIRT_CODE.fd"
  fi

  if [[ -z "$EDK2_CODE" ]]; then
    echo "WARNING: EDK2 UEFI firmware not found. Creating empty vars file."
    dd if=/dev/zero of="$VARS_FILE" bs=1M count=32 2>/dev/null
  else
    echo "    Using EDK2 code file: $EDK2_CODE"
    cp "$EDK2_CODE" "$VARS_FILE"
  fi
fi

# --- Generate cloud-init ISO ---
CLOUD_INIT_ISO="cloud-init.iso"
if [[ -f "$CLOUD_INIT_ISO" ]]; then
  echo "==> Found existing ${CLOUD_INIT_ISO}"
else
  echo "==> Generating cloud-init ISO..."
  if command -v genisoimage &>/dev/null; then
    genisoimage -output "$CLOUD_INIT_ISO" \
      -volid cidata -joliet -rock \
      cloud-init/user-data cloud-init/meta-data
  elif command -v mkisofs &>/dev/null; then
    mkisofs -output "$CLOUD_INIT_ISO" \
      -volid cidata -joliet -rock \
      cloud-init/user-data cloud-init/meta-data
  else
    echo "WARNING: genisoimage/mkisofs not found."
    echo "         Cloud-init will not work without the ISO."
    echo ""
    echo "Install genisoimage:"
    if [[ "$(uname)" == "Darwin" ]]; then
      echo "  brew install cdrtools"
    else
      echo "  sudo apt-get install genisoimage  # Debian/Ubuntu"
      echo "  sudo dnf install genisoimage      # Fedora"
    fi
  fi
fi

echo ""
echo "==> Setup complete!"
echo ""
echo "To start the VM:"
echo "  ./run.sh"
echo ""
echo "Default login (after cloud-init runs):"
echo "  username: fedora"
echo "  password: fedora"
echo ""
echo "SSH access:"
echo "  ssh -p 2222 fedora@localhost"
echo ""
