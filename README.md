# Monolithic 3D JSCAN Architecture for 3-Tier IC Testing

![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![PDK](https://img.shields.io/badge/PDK-Sky130A-blue)
![Flow](https://img.shields.io/badge/Flow-OpenLane-FF6B00)
![RL](https://img.shields.io/badge/Optimized-PPO_RL-green)
![3D-IC](https://img.shields.io/badge/Tech-Monolithic_3D-8A2BE2)

**Complete RTL-to-GDSII Monolithic 3D Joint Scan Architecture (JSCAN) with PPO Reinforcement Learning for ultra-low routing congestion and power optimisation.**

## ✨ Project Highlights

- **3-Tier Monolithic 3D JSCAN** with SAS, RAS, and scan modes
- Global Test Controller (GTC) dynamically cycles tiers, modes, columns
- Per-tier MISR for fault signature aggregation → single `fault_flag`
- Full OpenLane flow on **Sky130A** PDK (DRC/LVS clean)
- **PPO RL agent** automatically tunes density, die area, core utilization & routing adjustments
- **Up to 39% reduction** in maximum routing congestion vs default flow

## 📁 Repository Structure
```text
Monolithic-3D-JSCAN-Architecture-IC/
├── RTL/                          # All Verilog RTL files
│   ├── JSCAN_TOP.v               # Top-level 3-tier integration
│   ├── TIER_BLOCK.v              # Per-tier block (SAS + RAS + TSV)
│   ├── GTC.v                     # Global Test Controller
│   ├── MSS.v                     # Multi-bit Scan Chain (SAS mode)
│   ├── PRAS.v                    # Pseudo-Random Access Scan
│   ├── LC.v                      # Layer Connections
│   ├── MISR.v                    # Multiple Input Signature Register
│   └── JSCAN_TB.v                # Testbench with corner cases
├── ASIC_FLOW/                    # OpenLane results & final outputs
│   └── reports/                  # Congestion, timing, DRC reports
├── RL/                           # Reinforcement Learning MODELs
└── README.md
```

## 🏗️ Architecture

**3-Tier Monolithic 3D JSCAN**
- Each tier contains: MSS (Serial), PRAS (Random Access), LC 
- Global Test Controller orchestrates all modes
- Built-in MISR on every tier
- Supports at-speed testing with shift/capture control



## 🚀 Quick Start (Ubuntu)

### 1. Setup Design
```bash
cd ~/OpenLane
mkdir -p designs/top_3d_jscan/src
cp /path/to/your/RTL/*.v designs/top_3d_jscan/src/

cd ~/ppo_openlane_final

# Step 1: Fast surrogate training (4-8 min)
python jscan_rl_best_v2.py --surrogate --steps 6000

# Step 2: Real optimization with auto-cleanup (25-50 min)
python jscan_rl_best_v2.py --real --steps 80

cd ~/OpenLane
make DESIGN=top_3d_jscan \
     INIT_DEF=~/rl_jscan_best/best_low_congestion.def \
     TAG=rl_low_congestion_jscan

```
Final GDS: ~/OpenLane/designs/top_3d_jscan/runs/rl_low_congestion_jscan/results/final/top_3d_jscan.gds
