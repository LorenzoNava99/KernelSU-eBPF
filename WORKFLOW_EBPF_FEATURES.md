# Workflow eBPF Feature Matrix

## Workflow Files and Their eBPF Capabilities

### 1. `build-kernel-a14.yml` - Base (No eBPF)
**Name:** Build A14 Kernel - Basic (No eBPF)
- **eBPF Features:** NONE
- **BTF Support:** ❌
- **BPF Override:** ❌
- **Purpose:** Basic Android 14 kernel builds without eBPF

---

### 2. `build-kernel-a14-ebpf.yml` - Full eBPF Stack
**Name:** Build A14 Kernel - Full eBPF + BTF + Override + ARM64 Support
- **Config:** `ebpf_safe_enhanced.fragment`
- **eBPF Features:**
  - ✅ Core BPF (CONFIG_BPF=y, CONFIG_BPF_SYSCALL=y)
  - ✅ BPF JIT (CONFIG_BPF_JIT=y, CONFIG_BPF_JIT_ALWAYS_ON=y)
  - ✅ **bpf_override_return()** (CONFIG_BPF_KPROBE_OVERRIDE=y)
  - ✅ **Function Error Injection** (CONFIG_FUNCTION_ERROR_INJECTION=y)
  - ✅ **ARM64 Error Injection** (CONFIG_HAVE_FUNCTION_ERROR_INJECTION=y)
  - ✅ **BTF & CO-RE** (CONFIG_DEBUG_INFO_BTF=y, CONFIG_BPF_CO_RE=y)
  - ✅ **All Map Types:**
    - Per-CPU maps
    - LRU hash maps
    - LPM trie
    - Stack trace maps
    - Queue/Stack maps
    - **Ring buffers** (CONFIG_BPF_RINGBUF=y)
  - ✅ **Kprobes/Kretprobes** (CONFIG_KPROBES=y, CONFIG_KRETPROBES=y)
  - ✅ **Uprobes** (CONFIG_UPROBE_EVENTS=y)
  - ✅ **Dynamic Ftrace with Regs** (CONFIG_DYNAMIC_FTRACE_WITH_REGS=y)
  - ✅ **Syscall Tracing** (CONFIG_FTRACE_SYSCALLS=y)
  - ✅ **Performance Events** (CONFIG_PERF_EVENTS=y)
  - ✅ **Cgroup BPF** (CONFIG_CGROUP_BPF=y)
  - ✅ **Socket Operations** (CONFIG_BPF_SOCK_OPS=y)
  - ✅ **Raw Tracepoints** (CONFIG_RAW_TRACEPOINT=y)
  - ❌ BPF LSM (disabled - conflicts with SELinux)
  - ❌ XDP (disabled - too heavy for Android)

---

### 3. `build-kernel-6.1-ebpf-only.yml` - 6.1.1x Focused
**Name:** Build 6.1.1x Only - eBPF + BTF + All Map Types + Ring Buffers
- **Config:** Same as above (`ebpf_safe_enhanced.fragment`)
- **Targets:** Only Android 14 6.1.112, 6.1.115, 6.1.118
- **Purpose:** Optimized builds for 6.1.1x kernels with full eBPF

---

### 4. `gki-kernel.yml` - Base Template
**Name:** GKI Kernel - Base (No eBPF)
- **eBPF Features:** NONE
- **Purpose:** Base workflow template for standard GKI builds

---

### 5. `gki-kernel-ebpf.yml` - Enhanced Template
**Name:** GKI Kernel - eBPF Safe Enhanced (BTF+Override+RingBuf+ARM64)
- **Config:** `ebpf_safe_enhanced.fragment`
- **Purpose:** Reusable workflow template with full eBPF stack
- **Called by:** `build-kernel-a14-ebpf.yml`, `build-kernel-6.1-ebpf-only.yml`

## Feature Comparison Table

| Feature | Base | eBPF Enhanced |
|---------|------|---------------|
| CONFIG_BPF | ❌ | ✅ |
| CONFIG_BPF_SYSCALL | ❌ | ✅ |
| CONFIG_BPF_JIT | ❌ | ✅ |
| CONFIG_BPF_KPROBE_OVERRIDE | ❌ | ✅ |
| CONFIG_FUNCTION_ERROR_INJECTION | ❌ | ✅ |
| CONFIG_DEBUG_INFO_BTF | ❌ | ✅ |
| CONFIG_BPF_CO_RE | ❌ | ✅ |
| CONFIG_BPF_RINGBUF | ❌ | ✅ |
| CONFIG_KPROBES | ❌ | ✅ |
| CONFIG_KRETPROBES | ❌ | ✅ |
| CONFIG_UPROBE_EVENTS | ❌ | ✅ |
| CONFIG_PERF_EVENTS | ❌ | ✅ |
| CONFIG_CGROUP_BPF | ❌ | ✅ |
| ARM64 Error Injection | ❌ | ✅ |

## Key eBPF Capabilities Enabled

### bpf_override_return()
- **Enabled by:** CONFIG_BPF_KPROBE_OVERRIDE + CONFIG_FUNCTION_ERROR_INJECTION
- **ARM64 Support:** Added via custom patch
- **Use Case:** Override kernel function return values for error injection

### BTF (BPF Type Format)
- **Enabled by:** CONFIG_DEBUG_INFO_BTF + CONFIG_BPF_CO_RE
- **Use Case:** CO-RE (Compile Once, Run Everywhere) for portable BPF programs

### Ring Buffers
- **Enabled by:** CONFIG_BPF_RINGBUF
- **Use Case:** Efficient data transfer between kernel and userspace

### All Tracing Mechanisms
- Kprobes: Dynamic kernel probes
- Kretprobes: Return probes for measuring function duration
- Uprobes: User-space probes for Android app tracing
- Ftrace: Function tracer with syscall support

## Usage

To build with eBPF features:
```bash
# Trigger the eBPF-enabled workflow
gh workflow run "Build A14 Kernel - Full eBPF + BTF + Override + ARM64 Support"
```

To build without eBPF:
```bash
# Trigger the basic workflow
gh workflow run "Build A14 Kernel - Basic (No eBPF)"
```