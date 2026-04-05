# Monolithic 3D JSCAN Architecture for 3-Tier IC Testing

![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![PDK](https://img.shields.io/badge/PDK-Sky130A-blue)
![Flow](https://img.shields.io/badge/Flow-OpenLane-FF6B00)
![RL](https://img.shields.io/badge/Optimized-PPO_RL-green)
![3D-IC](https://img.shields.io/badge/Tech-Monolithic_3D-8A2BE2)

**Complete RTL-to-GDS Monolithic 3D Joint Scan Architecture (JSCAN) with PPO Reinforcement Learning for ultra-low routing congestion and power optimisation.**

## ✨ Project Highlights

- **3-Tier Monolithic 3D JSCAN** with SAS, RAS, and scan modes
- Global Test Controller (GTC) dynamically cycles tiers, modes, columns
- Per-tier MISR for fault signature aggregation → single `fault_flag`
- Full OpenLane flow on **Sky130A** PDK (DRC/LVS clean)
- **PPO RL agent** automatically tunes density, die area, core utilization & routing adjustments
- **Up to 39.66% reduction** in maximum routing congestion vs default flow

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
├── IMAGES/                       # Images
├── RL/                           # Reinforcement Learning MODELs 
├── 3D_JSCAN_V2                   # Contains results from Cadence
└── README.md
```
## 🏗️ Openlane flow 

![Result](IMAGES/OPENLANE_FLOW.png)

## 🏗️ Proposed Architecture

**3-Tier Monolithic 3D JSCAN**
- Each tier contains: MSS (Serial), PRAS (Random Access), LC 
- Global Test Controller orchestrates all modes
- Built-in MISR on every tier
- Supports at-speed testing with shift/capture control
  
![Result](IMAGES/JSCAN_ARC.jpg)
![Result](IMAGES/1.png)

## ✨ Results

![Result](IMAGES/RESULT.png)
![Result](IMAGES/036d183b-00ab-4d23-aab8-1a5b3281a6ab.jpeg)
## Ubuntu
### 1. Setup Design
```bash
cd ~/ppo_openlane_final
source ~/openlane-venv/bin/activate
python jscan_rl_pro_v7.py
```
Final GDS: ~/OpenLane/designs/top_3d_jscan/runs/rl_low_congestion_jscan/results/final/top_3d_jscan.gds
