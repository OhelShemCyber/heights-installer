# Heights Python Installer – IT Deployment Guide

This tool installs a fully managed Python programming environment for Heights high school students.

---

## ✅ What the Installer Does

- Installs:
  - Miniconda (Latest) → `C:\Heights\Miniconda`
  - Pycharm Community (Installs or Updates to Latest only if pro not installed) → `Defualt Pycharm`
  - Project folder → `C:\Programming\TestProject`

- Installs these Python packages:
  - `scapy`, `requests`, `flask`, `Pillow`

---

## 🔧 What It Changes on the System

- Removes all other Python-related paths from PATH  
- Registers Miniconda as the default Python
- Creates folders:
  - `C:\Heights`
  - `C:\Programming`

---

## 🧹 What Happens on Uninstall

- Nothing

---

## 📂 Branding & Appearance

- Setup and uninstall icons use `Heights.ico`
- Start Menu folder:
  - "Uninstall Heights Tools"

---

## 🧪 Notes for IT Teams

- All installation is **silent**: Next → Next → Finish
- No user input required
- Fully reversible using miniconda and pycharm regular uninstallers
