# ⚡ AxiomGrulerInjector – Minecraft DLL Injector for minecraft bedrock. Best optimized injector to exist.(Manual Map, Zero Traces)

A lightweight, open‑source injector for **Minecraft Java Edition** that uses **manual mapping** to load your DLL directly into the game process.  
No .exe files, no leftover junk, no performance hit – just a tiny shell script that creates a temporary PowerShell injector and deletes it the moment the job is done.

**Faster than Feather, cleaner than Feather, and fully transparent.**

---

## ✨ Features

- **No `.exe`** – runs as a plain `.sh` script via Git Bash (no compiled binaries, no antivirus flags)
- **Manual map injection** – your DLL is mapped manually, keeping it hidden and efficient
- **Zero traces** – a temporary PowerShell file is created *only* during injection and automatically deleted afterwards
- **Low footprint** – extremely low CPU & RAM usage during injection, no background processes left behind
- **Instantly exits** – the injector closes itself right after the DLL is loaded; Minecraft runs as if nothing happened
- **Works perfectly** – reliable, fast, and designed specifically for Minecraft
- **Open source** – view the entire logic by simply renaming `inject.sh` to `.txt`

---

## 📋 Requirements

- **Windows** (7/8/10/11)  
- **Git for Windows** *(most people already have it)* – needed to run the `.sh` script  
  [Download Git](https://git-scm.com/download/win)  
- **Minecraft Java Edition** – already running before injection  
- A compiled **DLL** file you want to inject

---

## 🚀 How to Use

1. **Make sure Minecraft is running** (the Java process, usually `javaw.exe`).
2. Open **Git Bash**.
3. Navigate to the folder containing `inject.sh`.
4. Run the injector with the path to your DLL:
   ```bash
   ./inject.sh "C:\path\to\your.dll"
