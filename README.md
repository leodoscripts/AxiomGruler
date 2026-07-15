# 🚀 AxiomGRulerInjector

An ultra-optimized, open-source, and stealthy DLL injector designed exclusively for **Minecraft: Bedrock Edition (Windows)**. 

Unlike traditional heavy injectors that run as compiled executables (`.exe`), **AxiomGRulerInjector** is a lightweight shell script (`.sh`) that dynamically generates a temporary PowerShell execution thread to handle the injection, cleaning up entirely after itself.

---

## ✨ Features

*   **Zero Footprint (`.exe`-Free):** Written entirely as a shell script (`.sh`). No suspicious executables, no closed-source compiled files.
*   **Open Source & Transparent:** To view or audit the source code, simply rename `inject.sh` to `inject.txt`. 
*   **Manual Mapping Support:** Uses advanced injection techniques to load your DLL directly into the game's memory space.
*   **Ultra Low Resource Usage:** Minimal CPU, virtually zero RAM impact, and absolutely no background lag.
*   **Self-Cleaning & Stealthy:** 
    *   Creates a temporary PowerShell injector script only during the active injection phase.
    *   Automatically deletes the temporary PowerShell file the millisecond the DLL is successfully loaded.
    *   The script closes itself immediately after completion, leaving Minecraft running flawlessly.
*   **Cleaner than the Competition:** Unlike other injectors (like Fate) which clutter your system by storing persistent files in your `%TEMP%` directories, **AxiomGRulerInjector** leaves behind absolutely zero residual files.

---

## 🛠️ Prerequisites

To run this injector on Windows, you only need one thing:
*   **Git for Windows** (specifically **Git Bash** to execute the `.sh` file). 
    > *Note: Most developers and power users already have this installed! If you don't, you can grab it from [git-scm.com](https://git-scm.com/).*

---

## 🚀 How to Use

1. **Clone or Download** this repository.
2. Place the **DLL** you want to inject into the same folder as `inject.sh`.
3. Open **Git Bash** in this directory.
4. Run **AxiomGRulerInjector**:
   ```bash
   ./inject.sh
