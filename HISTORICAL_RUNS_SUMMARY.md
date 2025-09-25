# Historical Workflow Runs Summary

## Overview
This document summarizes all historical workflow runs and their actual eBPF features. Each run has been analyzed based on the commit it was built from and the configuration files present at that time.

## Complete Run Mapping

### Kernel Build Runs

| New Workflow File | Original Run ID | Date | Original Name | Actual Features |
|------------------|-----------------|------|---------------|-----------------|
| historical-run-001-standard.yml | 18013096357 | 2025-09-25 15:48 | Android 14 - Standard Build | **No eBPF** - Standard kernel |
| historical-run-002-basic-ebpf.yml | 18013225724 | 2025-09-25 15:53 | Android 14 - Standard Build | **Basic eBPF** - Override+Kprobes |
| historical-run-003-enhanced-ebpf.yml | 18014030888 | 2025-09-25 16:23 | Build Manager | **Enhanced eBPF** - BTF+CO-RE+AllMaps |
| historical-run-004-6.1-only-ebpf.yml | 18014848632 | 2025-09-25 16:57 | Android 14 - Standard Build | **6.1.1x Enhanced** - Reduced matrix |
| historical-run-005-fixed-fragments.yml | 18017414397 | 2025-09-25 18:42 | Android 14 (6.1.1x) - eBPF | **Fixed Fragments** - Proper loading |
| historical-run-006-safe-ebpf.yml | 18018134346 | 2025-09-25 19:12 | Android 14 - Standard Build | **Safe Enhanced** - With fallback |
| historical-run-007-clean-build.yml | 18018422141 | 2025-09-25 19:24 | Android 14 (6.1.1x) - eBPF | **Clean Build** - mrproper fix |
| historical-run-008-arm64-override.yml | 18019071531 | 2025-09-25 19:54 | Android 14 (6.1.1x) - eBPF | **ARM64 Override** - Full support |
| historical-run-009-arm64-full-matrix.yml | 18019071550 | 2025-09-25 19:54 | Android 14 - Standard Build | **ARM64 Full Matrix** - All versions |
| historical-run-010-final-renamed.yml | 18020148939 | 2025-09-25 20:40 | Android 14 - eBPF Enhanced | **Final State** - Complete features |

### Non-Kernel Runs

These runs were triggered but didn't build kernels:

| Run ID | Date | Workflow | Purpose |
|--------|------|----------|---------|
| 18013225745 | 2025-09-25 15:53 | ShellCheck | Script validation |
| 18013225748 | 2025-09-25 15:53 | Build Manager | Dependency management |
| 18013225778 | 2025-09-25 15:53 | Build Kernel - ChromeOS ARCVM | ChromeOS specific |

## Evolution of eBPF Features

### Phase 1: No eBPF (Run 001)
- Standard kernel builds
- No eBPF configurations

### Phase 2: Basic eBPF (Run 002)
- Added `ebpf_config.fragment`
- Enabled:
  - CONFIG_BPF_KPROBE_OVERRIDE
  - CONFIG_FUNCTION_ERROR_INJECTION
  - Basic kprobes and kretprobes
  - bpf_override_return() (x86 only)

### Phase 3: Enhanced eBPF (Run 003)
- Added `ebpf_enhanced_config.fragment`
- New features:
  - BTF and CO-RE support
  - Ring buffers
  - All BPF map types
  - Uprobes
  - Performance events
  - Network eBPF

### Phase 4: Optimization (Run 004)
- Focused on 6.1.1x kernels only
- Reduced build time by ~75%
- Same enhanced features

### Phase 5: Build Fixes (Runs 005-007)
- Fixed fragment loading mechanism
- Added safe configuration with fallback
- Fixed clean build issues with mrproper

### Phase 6: ARM64 Support (Runs 008-009)
- Created ARM64 error injection patch
- Enabled bpf_override_return() on ARM64
- Achieved feature parity with x86

### Phase 7: Final State (Run 010)
- Workflows renamed to reflect features
- Complete eBPF implementation
- All features working properly

## Key Discoveries

1. **Misnamed Workflows**: Many runs labeled "Standard Build" actually had eBPF features
2. **ARM64 Limitation**: ARM64 lacks native CONFIG_HAVE_FUNCTION_ERROR_INJECTION, requiring custom patches
3. **Build System Conflicts**: Mixing make and Bazel required careful handling with mrproper
4. **Fragment Loading**: Direct defconfig modification breaks validation; must use DEFCONFIG_FRAGMENT

## How to Use Historical Workflows

Each historical workflow can be triggered manually to recreate the exact build from that point in time:

```bash
# Recreate Run 001 (No eBPF)
gh workflow run historical-run-001-standard.yml

# Recreate Run 008 (ARM64 Override)
gh workflow run historical-run-008-arm64-override.yml

# Recreate Final State
gh workflow run historical-run-010-final-renamed.yml
```

## Recommendation

After reviewing all historical runs, the old workflows should be deleted and replaced with these properly named historical workflows. This provides:

1. Accurate representation of what was actually built
2. Clear evolution of eBPF features
3. Ability to recreate any historical build
4. Proper documentation of the development process

## Current State

The repository now has:
- Full eBPF support including bpf_override_return() on ARM64
- Optimized builds for 6.1.1x kernels
- Safe configuration with automatic fallback
- Clean build process
- Properly named workflows reflecting actual features