# KernelSU with Enhanced eBPF Support

## Overview
This build includes comprehensive eBPF (Extended Berkeley Packet Filter) support for Android, enabling advanced system tracing, monitoring, and modification capabilities without needing Frida or other traditional hooking frameworks.

## Key Features

### 🎯 Core Capabilities
- **`bpf_override_return()`** - Override function return values
- **Kprobes/Kretprobes** - Trace kernel function entry/exit
- **Uprobes** - Trace userspace functions
- **Raw Tracepoints** - Low-overhead tracing
- **BPF LSM** - Security hooks via eBPF
- **BTF Support** - CO-RE (Compile Once, Run Everywhere)

### 📊 Enhanced Tracing
- **Function Graph Tracer** - Complete call chain analysis
- **Syscall Tracing** - Monitor all system calls
- **Dynamic Ftrace** - Runtime function tracing
- **Stack Traces** - Full kernel and user stack unwinding

### 🗺️ Advanced Map Types
All BPF map types are enabled:
- Arrays (regular and per-CPU)
- Hash maps (regular, LRU, per-CPU)
- Stack traces
- Ring buffers
- Socket maps
- Device maps
- Cgroup arrays

### 🔒 Security Features
- **BPF LSM** - Implement security policies
- **Unprivileged BPF disabled by default** - Secure by default
- **BPF signing support** - Verify BPF programs
- **Function error injection** - Test error paths

### 📱 Android-Specific
- **Binder tracing** - Monitor IPC calls
- **Cgroup BPF** - Resource management
- **Network filtering** - TC/XDP programs
- **Time-in-state tracking** - Power management

## Configuration Details

### Essential Configs
```bash
CONFIG_BPF_KPROBE_OVERRIDE=y       # Enable bpf_override_return()
CONFIG_FUNCTION_ERROR_INJECTION=y   # Prerequisite for override
CONFIG_BPF_EVENTS=y                # BPF event support
CONFIG_DEBUG_INFO_BTF=y            # BTF for CO-RE
CONFIG_BPF_LSM=y                   # Security hooks
```

### Program Types Enabled
- Socket filters
- Kprobe/Kretprobe programs
- TC classifiers and actions
- XDP programs
- Cgroup socket programs
- Cgroup device programs
- LWT programs
- Raw tracepoint programs
- Socket reuseport programs
- Flow dissector programs

## Usage Examples

### 1. Check eBPF Support
```bash
# Run on device as root
sh /data/local/tmp/ebpf_android_helpers.sh --check
```

### 2. Override Function Return (C Example)
```c
SEC("kprobe/sys_openat")
int BPF_KPROBE(override_openat, int dfd, const char *filename)
{
    char comm[16];
    bpf_get_current_comm(comm, sizeof(comm));

    // Block specific app from opening files
    if (strstr(comm, "target_app")) {
        bpf_override_return(ctx, -EACCES);
        return 0;
    }
    return 0;
}
```

### 3. Trace Binder Transactions
```c
SEC("tracepoint/binder/binder_transaction")
int trace_binder(void *ctx)
{
    // Access binder transaction data
    // Log or filter IPC calls
    return 0;
}
```

### 4. Monitor Network Traffic
```c
SEC("tc")
int tc_monitor(struct __sk_buff *skb)
{
    // Inspect/modify network packets
    // Implement firewall rules
    return TC_ACT_OK;
}
```

## Helper Script Functions

The included `ebpf_android_helpers.sh` provides:

1. **Check eBPF Support** - Verify kernel capabilities
2. **Mount Filesystems** - Setup debugfs/tracefs/bpffs
3. **Configure Limits** - Set memory and JIT limits
4. **List Programs** - Show loaded BPF programs
5. **Android Features** - Check Android-specific BPF

## Building Custom eBPF Programs

### Prerequisites
```bash
# On build machine
apt install clang llvm libbpf-dev

# For Android
# Use Android NDK's clang
```

### Compilation
```bash
# Compile eBPF program
clang -O2 -target bpf -c program.c -o program.o

# Load on Android (requires root)
bpftool prog load program.o /sys/fs/bpf/myprog
```

## Performance Benefits

Compared to traditional hooking methods:
- **Lower overhead** - JIT compiled to native code
- **No context switches** - Runs in kernel space
- **Safe** - Verified before loading
- **Flexible** - Attach to any kernel function

## Security Considerations

1. **Root Required** - BPF programs need root to load
2. **Verifier** - All programs are verified for safety
3. **Resource Limits** - Memory usage is controlled
4. **Unprivileged BPF** - Disabled by default for security

## Advantages Over Frida

| Feature | eBPF | Frida |
|---------|------|-------|
| Performance | Very High | Moderate |
| Kernel Access | Yes | Limited |
| Verification | Yes | No |
| Overhead | Minimal | Significant |
| Persistence | Yes | No |
| Native Speed | Yes | No |

## Troubleshooting

### BPF Program Won't Load
- Check verifier output: `dmesg | grep -i bpf`
- Ensure BTF is available: `/sys/kernel/btf/vmlinux`
- Verify permissions: Must be root

### Override Not Working
- Confirm `CONFIG_BPF_KPROBE_OVERRIDE=y`
- Check if function has `ALLOW_ERROR_INJECTION`
- Verify kprobe is at function entry

### No BTF Information
- Kernel must be built with `CONFIG_DEBUG_INFO_BTF=y`
- Check `/sys/kernel/btf/vmlinux` exists

## Advanced Features Available

- **BPF-to-BPF calls** - Modular programs
- **Tail calls** - Dynamic program chaining
- **Global variables** - Persistent state
- **Spinlocks** - Synchronization primitives
- **Timer callbacks** - Delayed execution
- **Ring buffer** - Efficient event streaming

## Limitations

1. **Stack size** - Limited to 512 bytes
2. **Instruction limit** - 1M instructions (with loops)
3. **No floating point** - Integer arithmetic only
4. **Restricted helpers** - Only safe kernel functions

## Resources

- [eBPF.io](https://ebpf.io) - eBPF documentation
- [Android eBPF](https://source.android.com/docs/core/architecture/kernel/bpf) - Android-specific docs
- [libbpf](https://github.com/libbpf/libbpf) - User-space library
- [BCC](https://github.com/iovisor/bcc) - BPF Compiler Collection

## Contributing

To add more eBPF features:
1. Edit `kernel/ebpf_enhanced_config.fragment`
2. Test on multiple Android versions
3. Ensure no boot failures
4. Document new capabilities

## License

This eBPF enhancement maintains compatibility with KernelSU's GPL-3.0 license.