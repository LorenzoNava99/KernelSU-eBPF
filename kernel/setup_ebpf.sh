#!/bin/sh
set -eu

GKI_ROOT=$(pwd)

display_usage() {
    echo "Usage: $0 [--cleanup | <commit-or-tag>]"
    echo "  --cleanup:              Cleans up previous modifications made by the script."
    echo "  <commit-or-tag>:        Sets up or updates the KernelSU to specified tag or commit."
    echo "  -h, --help:             Displays this usage information."
    echo "  (no args):              Sets up or updates the KernelSU environment with eBPF support."
}

initialize_variables() {
    if test -d "$GKI_ROOT/common/drivers"; then
         DRIVER_DIR="$GKI_ROOT/common/drivers"
    elif test -d "$GKI_ROOT/drivers"; then
         DRIVER_DIR="$GKI_ROOT/drivers"
    else
         echo '[ERROR] "drivers/" directory not found.'
         exit 127
    fi

    DRIVER_MAKEFILE=$DRIVER_DIR/Makefile
    DRIVER_KCONFIG=$DRIVER_DIR/Kconfig

    # Find kernel config directory
    if test -d "$GKI_ROOT/common/arch/arm64/configs"; then
        CONFIG_DIR="$GKI_ROOT/common/arch/arm64/configs"
    elif test -d "$GKI_ROOT/arch/arm64/configs"; then
        CONFIG_DIR="$GKI_ROOT/arch/arm64/configs"
    else
        echo '[WARNING] ARM64 config directory not found, eBPF config will be applied differently.'
        CONFIG_DIR=""
    fi
}

# Apply eBPF configuration
apply_ebpf_config() {
    echo "[+] Applying eBPF configuration..."

    # Copy eBPF config fragment to kernel source
    if [ -n "$CONFIG_DIR" ]; then
        cp "$GKI_ROOT/KernelSU/kernel/ebpf_config.fragment" "$CONFIG_DIR/" && echo "[+] eBPF config fragment copied."

        # Apply to GKI defconfig if exists
        if [ -f "$CONFIG_DIR/gki_defconfig" ]; then
            echo "[+] Merging eBPF config with gki_defconfig..."
            cat "$CONFIG_DIR/ebpf_config.fragment" >> "$CONFIG_DIR/gki_defconfig"
        fi
    fi

    # Also apply to build.config if exists
    if [ -f "$GKI_ROOT/common/build.config.gki.aarch64" ]; then
        echo "[+] Adding eBPF fragment to build config..."
        if ! grep -q "ebpf_config.fragment" "$GKI_ROOT/common/build.config.gki.aarch64"; then
            echo "FRAGMENT_CONFIG=arch/arm64/configs/ebpf_config.fragment" >> "$GKI_ROOT/common/build.config.gki.aarch64"
        fi
    fi

    echo "[+] eBPF configuration applied."
}

# Reverts modifications made by this script
perform_cleanup() {
    echo "[+] Cleaning up..."
    [ -L "$DRIVER_DIR/kernelsu" ] && rm "$DRIVER_DIR/kernelsu" && echo "[-] Symlink removed."
    grep -q "kernelsu" "$DRIVER_MAKEFILE" && sed -i '/kernelsu/d' "$DRIVER_MAKEFILE" && echo "[-] Makefile reverted."
    grep -q "drivers/kernelsu/Kconfig" "$DRIVER_KCONFIG" && sed -i '/drivers\/kernelsu\/Kconfig/d' "$DRIVER_KCONFIG" && echo "[-] Kconfig reverted."

    # Clean eBPF configs
    if [ -n "$CONFIG_DIR" ]; then
        [ -f "$CONFIG_DIR/ebpf_config.fragment" ] && rm "$CONFIG_DIR/ebpf_config.fragment" && echo "[-] eBPF config fragment removed."
    fi

    if [ -d "$GKI_ROOT/KernelSU" ]; then
        rm -rf "$GKI_ROOT/KernelSU" && echo "[-] KernelSU directory deleted."
    fi
}

# Sets up or update KernelSU environment with eBPF support
setup_kernelsu() {
    echo "[+] Setting up KernelSU with eBPF support..."
    test -d "$GKI_ROOT/KernelSU" || git clone https://github.com/tiann/KernelSU && echo "[+] Repository cloned."
    cd "$GKI_ROOT/KernelSU"
    git stash && echo "[-] Stashed current changes."
    if [ "$(git status | grep -Po 'v\d+(\.\d+)*' | head -n1)" ]; then
        git checkout main && echo "[-] Switched to main branch."
    fi
    git pull && echo "[+] Repository updated."
    if [ -z "${1-}" ]; then
        git checkout "$(git describe --abbrev=0 --tags)" && echo "[-] Checked out latest tag."
    else
        git checkout "$1" && echo "[-] Checked out $1." || echo "[-] Checkout default branch"
    fi
    cd "$DRIVER_DIR"
    ln -sf "$(realpath --relative-to="$DRIVER_DIR" "$GKI_ROOT/KernelSU/kernel")" "kernelsu" && echo "[+] Symlink created."

    # Add entries in Makefile and Kconfig if not already existing
    grep -q "kernelsu" "$DRIVER_MAKEFILE" || printf "\nobj-\$(CONFIG_KSU) += kernelsu/\n" >> "$DRIVER_MAKEFILE" && echo "[+] Modified Makefile."
    grep -q "source \"drivers/kernelsu/Kconfig\"" "$DRIVER_KCONFIG" || sed -i "/endmenu/i\source \"drivers/kernelsu/Kconfig\"" "$DRIVER_KCONFIG" && echo "[+] Modified Kconfig."

    # Apply eBPF configuration
    apply_ebpf_config

    echo '[+] Done. KernelSU with eBPF support is ready.'
}

# Process command-line arguments
if [ "$#" -eq 0 ]; then
    initialize_variables
    setup_kernelsu
elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    display_usage
elif [ "$1" = "--cleanup" ]; then
    initialize_variables
    perform_cleanup
else
    initialize_variables
    setup_kernelsu "$@"
fi