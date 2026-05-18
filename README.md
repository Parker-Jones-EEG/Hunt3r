# 💻 Hunt3r Engine v8.0 — Safe Recon Framework

Hunt3r is a lightweight, modular reconnaissance framework built for authorized security testing and Vulnerability Disclosure Programs (VDPs).

It focuses on safe attack surface mapping only, including:
- Subdomain enumeration
- Directory discovery
- Service and port fingerprinting

It intentionally avoids exploitation features and intrusive scanning to remain VDP-compliant.

---

# ⚙️ Features

- Single-command execution mode (`--target example.com`)
- Built-in scope enforcement system
- Safe recon-only scanning pipeline
- Subdomain enumeration (Sublist3r support + auto-detect pathing)
- Live host filtering (httpx support)
- Directory discovery (Dirsearch)
- Service & port fingerprinting (Nmap safe mode)
- Auto file cleanup per run
- Interactive fallback mode if no arguments are provided
- VDP-safe by design (no exploitation modules)

---

# 🛠️ Included Tools

## Sublist3r
Used for passive subdomain discovery and external attack surface mapping.

## httpx
Filters and validates live web hosts before deeper scanning.

## Dirsearch
Performs lightweight directory and endpoint discovery on web assets.

## Nmap
Used for safe service detection and minimal port enumeration.

---

# 📌 Scope System

Hunt3r enforces scope before any scanning begins.

- Only approved domains are scanned
- Wildcards supported (e.g. *.example.com)
- Out-of-scope targets are blocked automatically

This helps maintain compliance with:
- HackerOne Vulnerability Disclosure Programs
- Bug bounty rules
- Responsible disclosure policies

---

# 🚀 Installation

git clone https://github.com/Parker-Jones-EEG/Hunt3r.git
cd Hunt3r
chmod +x hunt3r.sh

brew install nmap python3 git httpx

git clone https://github.com/aboul3la/Sublist3r.git ~/Sublist3r
pip3 install -r ~/Sublist3r/requirements.txt

git clone https://github.com/maurosoria/dirsearch.git ~/Sublist3r/dirsearch

---

# ▶️ Usage

## Single-command mode

./hunt3r.sh --target example.com

## Interactive mode

./hunt3r.sh

---

# 📦 Output Files

hunt3r_clean.txt — discovered subdomains  
live.txt — active hosts (httpx results)  
hunt3r_nmap.txt — service/port scan results  

---

# ⚖️ Legal & Ethical Use

This tool is intended only for authorized security testing.

Allowed:
- Vulnerability Disclosure Programs (VDPs)
- Bug bounty programs
- Explicit permission testing
- Owned infrastructure

Not allowed:
- Unauthorized scanning
- Exploitation or disruption of systems
- Out-of-scope targets

Users are responsible for compliance with laws and program rules.

---

# 📌 Disclaimer

This tool is provided for educational and defensive security research purposes only. The author assumes no liability for misuse or damages caused by this tool.
