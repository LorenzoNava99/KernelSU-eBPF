#!/system/bin/sh
# eBPF Android Helper Script
# Utilities for managing eBPF on Android devices

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo -e "${RED}This script must be run as root${NC}"
        exit 1
    fi
}

# Check eBPF support in kernel
check_ebpf_support() {
    echo -e "${GREEN}Checking eBPF Support...${NC}"

    # Check for BPF syscall
    if [ -e /proc/sys/kernel/unprivileged_bpf_disabled ]; then
        echo "✓ BPF syscall supported"
    else
        echo "✗ BPF syscall not found"
    fi

    # Check for BTF support
    if [ -e /sys/kernel/btf/vmlinux ]; then
        echo "✓ BTF (BPF Type Format) supported"
    else
        echo "✗ BTF not available"
    fi

    # Check for kprobe events
    if [ -e /sys/kernel/debug/tracing/kprobe_events ]; then
        echo "✓ Kprobe events supported"
    else
        echo "✗ Kprobe events not available"
    fi

    # Check for uprobe events
    if [ -e /sys/kernel/debug/tracing/uprobe_events ]; then
        echo "✓ Uprobe events supported"
    else
        echo "✗ Uprobe events not available"
    fi

    # Check for override return
    if grep -q "CONFIG_BPF_KPROBE_OVERRIDE=y" /proc/config.gz 2>/dev/null; then
        echo "✓ BPF override return supported"
    else
        echo "✗ BPF override return not available"
    fi

    # Check available program types
    echo -e "\n${YELLOW}Available BPF Program Types:${NC}"
    for prog_type in /sys/kernel/debug/tracing/available_filter_functions; do
        if [ -e "$prog_type" ]; then
            echo "✓ Tracing programs supported"
            break
        fi
    done
}

# Enable eBPF for unprivileged users (development only!)
enable_unprivileged_bpf() {
    echo -e "${YELLOW}Warning: Enabling unprivileged BPF (development only!)${NC}"
    if [ -e /proc/sys/kernel/unprivileged_bpf_disabled ]; then
        echo 0 > /proc/sys/kernel/unprivileged_bpf_disabled
        echo "✓ Unprivileged BPF enabled"
    else
        echo "✗ Cannot modify unprivileged BPF setting"
    fi
}

# Mount debugfs and tracefs if needed
mount_debug_filesystems() {
    echo -e "${GREEN}Mounting debug filesystems...${NC}"

    # Mount debugfs
    if ! mount | grep -q debugfs; then
        mount -t debugfs none /sys/kernel/debug
        echo "✓ Mounted debugfs"
    else
        echo "✓ debugfs already mounted"
    fi

    # Mount tracefs
    if ! mount | grep -q tracefs; then
        mount -t tracefs none /sys/kernel/debug/tracing
        echo "✓ Mounted tracefs"
    else
        echo "✓ tracefs already mounted"
    fi
}

# Set up BPF filesystem
setup_bpf_fs() {
    echo -e "${GREEN}Setting up BPF filesystem...${NC}"

    BPF_FS_PATH="/sys/fs/bpf"
    if [ ! -d "$BPF_FS_PATH" ]; then
        mkdir -p "$BPF_FS_PATH"
    fi

    if ! mount | grep -q "$BPF_FS_PATH"; then
        mount -t bpf none "$BPF_FS_PATH"
        echo "✓ Mounted BPF filesystem at $BPF_FS_PATH"
    else
        echo "✓ BPF filesystem already mounted"
    fi
}

# Configure BPF memory limits
configure_bpf_limits() {
    echo -e "${GREEN}Configuring BPF resource limits...${NC}"

    # Increase BPF memory limits
    if [ -e /proc/sys/kernel/bpf_jit_limit ]; then
        echo 1000000000 > /proc/sys/kernel/bpf_jit_limit
        echo "✓ Set BPF JIT limit to 1GB"
    fi

    # Enable BPF JIT
    if [ -e /proc/sys/net/core/bpf_jit_enable ]; then
        echo 1 > /proc/sys/net/core/bpf_jit_enable
        echo "✓ BPF JIT compiler enabled"
    fi

    # Enable BPF stats
    if [ -e /proc/sys/kernel/bpf_stats_enabled ]; then
        echo 1 > /proc/sys/kernel/bpf_stats_enabled
        echo "✓ BPF statistics enabled"
    fi
}

# List loaded BPF programs
list_bpf_programs() {
    echo -e "${GREEN}Loaded BPF Programs:${NC}"
    if [ -d /sys/fs/bpf ]; then
        find /sys/fs/bpf -type f 2>/dev/null | while read prog; do
            echo "  - $prog"
        done
    fi

    # Also check via bpftool if available
    if command -v bpftool >/dev/null 2>&1; then
        echo -e "\n${GREEN}BPF Programs (via bpftool):${NC}"
        bpftool prog list
    fi
}

# Check Android-specific eBPF features
check_android_ebpf() {
    echo -e "${GREEN}Android-specific eBPF features:${NC}"

    # Check for Android BPF loader
    if [ -e /system/bin/bpfloader ]; then
        echo "✓ Android BPF loader present"
    else
        echo "✗ Android BPF loader not found"
    fi

    # Check for netd BPF programs
    if [ -d /sys/fs/bpf/netd ]; then
        echo "✓ Netd BPF programs directory exists"
        ls /sys/fs/bpf/netd 2>/dev/null | head -5
    fi

    # Check for time_in_state BPF
    if [ -e /sys/fs/bpf/map_time_in_state_uid_time_in_state_map ]; then
        echo "✓ Time-in-state BPF tracking available"
    fi
}

# Main menu
show_menu() {
    echo -e "\n${GREEN}=== eBPF Android Helper ===${NC}"
    echo "1. Check eBPF support"
    echo "2. Mount debug filesystems"
    echo "3. Setup BPF filesystem"
    echo "4. Configure BPF limits"
    echo "5. List loaded BPF programs"
    echo "6. Check Android eBPF features"
    echo "7. Enable unprivileged BPF (DEV ONLY!)"
    echo "8. Run all checks"
    echo "9. Exit"
    echo -n "Select option: "
}

# Run all checks
run_all_checks() {
    check_ebpf_support
    echo ""
    mount_debug_filesystems
    echo ""
    setup_bpf_fs
    echo ""
    configure_bpf_limits
    echo ""
    check_android_ebpf
    echo ""
    list_bpf_programs
}

# Main execution
main() {
    check_root

    if [ "$#" -eq 1 ]; then
        case "$1" in
            --check)
                run_all_checks
                ;;
            --quick)
                check_ebpf_support
                ;;
            *)
                echo "Usage: $0 [--check|--quick]"
                exit 1
                ;;
        esac
    else
        while true; do
            show_menu
            read option
            case $option in
                1) check_ebpf_support ;;
                2) mount_debug_filesystems ;;
                3) setup_bpf_fs ;;
                4) configure_bpf_limits ;;
                5) list_bpf_programs ;;
                6) check_android_ebpf ;;
                7) enable_unprivileged_bpf ;;
                8) run_all_checks ;;
                9) exit 0 ;;
                *) echo "Invalid option" ;;
            esac
            echo -e "\nPress Enter to continue..."
            read
        done
    fi
}

main "$@"