# Individual Workflow Run Analysis

## Summary of All Runs

| Run ID | Date | Workflow | Commit | eBPF Features | Actual Functionality |
|--------|------|----------|---------|---------------|--------------------|
| 18013096357 | 2025-09-25 15:48 | Android 14 - Standard Build | 18ead4e3 | None | Standard kernel, no eBPF |
| 18013225724 | 2025-09-25 15:53 | Android 14 - Standard Build | a90d99ac | Basic eBPF | bpf_override_return() support |
| 18014030888 | 2025-09-25 16:23 | Build Manager | b5d27723 | Enhanced eBPF | Full eBPF stack with BTF |
| 18014848632 | 2025-09-25 16:57 | Android 14 - Standard Build | 04429c26 | Enhanced eBPF | 6.1.1x only with full eBPF |
| 18017414397 | 2025-09-25 18:42 | Android 14 (6.1.1x) - eBPF | d7d7bb13 | Enhanced eBPF | Fixed fragment loading |
| 18018134346 | 2025-09-25 19:12 | Android 14 - Standard Build | f6271379 | Safe Enhanced | Safe eBPF with fallback |
| 18018422141 | 2025-09-25 19:24 | Android 14 (6.1.1x) - eBPF | 1c26b99c | Safe Enhanced | Clean build fix |
| 18019071531 | 2025-09-25 19:54 | Android 14 (6.1.1x) - eBPF | 5355dbc9 | Full eBPF+ARM64 | ARM64 error injection |
| 18019071550 | 2025-09-25 19:54 | Android 14 - Standard Build | 5355dbc9 | Full eBPF+ARM64 | ARM64 error injection |
| 18020148939 | 2025-09-25 20:40 | Android 14 - eBPF Enhanced | 6c25db45 | Full eBPF+ARM64 | Renamed workflows |

## Detailed Analysis Per Run

### Run 1: 18013096357 - "Add workflow_dispatch trigger"
- **Commit**: 18ead4e3
- **Actual Features**: NO eBPF
- **What was built**: Standard Android 14 kernels
- **eBPF configs present**: None
- **Should be named**: "Android 14 Standard Build - Run 1 (No eBPF)"

### Run 2: 18013225724 - "Add eBPF support with bpf_override_return()"
- **Commit**: a90d99ac  
- **Actual Features**: Basic eBPF with override
- **What was built**: Android 14 kernels with ebpf_config.fragment
- **eBPF configs present**: ebpf_config.fragment (basic)
- **Features enabled**:
  - CONFIG_BPF_KPROBE_OVERRIDE
  - CONFIG_FUNCTION_ERROR_INJECTION
  - Basic kprobes
- **Should be named**: "Android 14 Basic eBPF - Run 2 (Override+Kprobes)"

### Run 3: 18014030888 - "Add enhanced eBPF support"
- **Commit**: b5d27723
- **Actual Features**: Enhanced eBPF 
- **What was built**: Full Android 14 matrix with ebpf_enhanced_config.fragment
- **eBPF configs present**: ebpf_enhanced_config.fragment
- **Features enabled**:
  - All from Run 2 plus:
  - BTF and CO-RE support
  - Ring buffers
  - All map types
  - Uprobes
  - Performance events
- **Should be named**: "Android 14 Enhanced eBPF - Run 3 (BTF+CO-RE+AllMaps)"

### Run 4: 18014848632 - "Focus builds on Android 6.1.1x"
- **Commit**: 04429c26
- **Actual Features**: Enhanced eBPF (6.1.1x only)
- **What was built**: Only 6.1.112, 6.1.115, 6.1.118 with eBPF
- **eBPF configs present**: ebpf_enhanced_config.fragment
- **Should be named**: "Android 14 6.1.1x eBPF - Run 4 (BTF+CO-RE+AllMaps)"

### Run 5: 18017414397 - "Fix eBPF build"
- **Commit**: d7d7bb13
- **Actual Features**: Enhanced eBPF with proper fragments
- **What was built**: 6.1.1x kernels with fixed fragment loading
- **eBPF configs present**: ebpf_enhanced_config.fragment
- **Should be named**: "Android 14 6.1.1x eBPF - Run 5 (Fixed Fragments)"

### Run 6: 18018134346 - "Add safe enhanced eBPF"
- **Commit**: f6271379
- **Actual Features**: Safe Enhanced eBPF
- **What was built**: Standard workflow but with safe eBPF
- **eBPF configs present**: ebpf_safe_enhanced.fragment (new)
- **Features enabled**: Safe subset with fallback
- **Should be named**: "Android 14 Safe eBPF - Run 6 (Fallback Config)"

### Run 7: 18018422141 - "Fix build errors"
- **Commit**: 1c26b99c
- **Actual Features**: Safe Enhanced with mrproper
- **What was built**: 6.1.1x with clean build
- **eBPF configs present**: ebpf_safe_enhanced.fragment
- **Should be named**: "Android 14 6.1.1x eBPF - Run 7 (Clean Build)"

### Run 8: 18019071531 - "Add ARM64 error injection"
- **Commit**: 5355dbc9
- **Actual Features**: FULL eBPF with ARM64 patches
- **What was built**: 6.1.1x with ARM64 error injection
- **eBPF configs present**: ebpf_safe_enhanced.fragment + ARM64 patch
- **Features enabled**: Everything including ARM64 bpf_override_return()
- **Should be named**: "Android 14 6.1.1x eBPF - Run 8 (ARM64 Override)"

### Run 9: 18019071550 - "Add ARM64 error injection" (duplicate)
- **Commit**: 5355dbc9
- **Actual Features**: FULL eBPF with ARM64 patches
- **What was built**: Full Android 14 matrix with ARM64
- **Should be named**: "Android 14 Full eBPF - Run 9 (ARM64 Override)"

### Run 10: 18020148939 - "Rename workflows"
- **Commit**: 6c25db45
- **Actual Features**: FULL eBPF with proper naming
- **What was built**: Android 14 with renamed workflows
- **Should be named**: "Android 14 eBPF Enhanced - Run 10 (Final)"
