# 💻 Hunt3r Engine v6.3 — Safe Recon Framework

Hunt3r is a lightweight, modular reconnaissance framework designed for authorized security testing and Vulnerability Disclosure Programs (VDPs).

It focuses on safe, non-intrusive attack surface mapping, including subdomain enumeration, directory discovery, and service fingerprinting.

This version is intentionally designed to remain compliant with most HackerOne-style VDP policies by excluding any exploitation or intrusive testing modules.

---

# ⚙️ Features

- Built-in scope enforcement system
- Safe recon-only scanning pipeline
- Subdomain enumeration (Sublist3r)
- Lightweight directory discovery (Dirsearch)
- Service and port fingerprinting (Nmap)
- Auto-generated recon reports
- Interactive module toggling system
- No exploitation tools included (VDP safe by design)

---

# 🛠️ Included Tools

## Sublist3r
Used for discovering subdomains and mapping external attack surfaces.

## Dirsearch
Performs lightweight directory and endpoint discovery on web assets.

## Nmap
Used for safe service detection and basic port scanning.

---

# 📌 Scope System

Before scanning, users must define allowed domains.

- Only in-scope targets are allowed
- Out-of-scope domains are automatically blocked
- Supports wildcards like *.example.com

This helps ensure compliance with:
- HackerOne Vulnerability Disclosure Programs
- Responsible disclosure policies
- Organization-specific security rules

---

# 🚀 Installation

git clone https://github.com/Parker-Jones-EEG/Hunt3r.git
cd Hunt3r
chmod +x Hunt3r.sh

sudo apt update
sudo apt install -y nmap python3 python3-pip git

git clone https://github.com/aboul3la/Sublist3r.git ~/Sublist3r
pip3 install -r ~/Sublist3r/requirements.txt

git clone https://github.com/maurosoria/dirsearch.git ~/Sublist3r/dirsearch

---

# ▶️ Usage

sudo ./Hunt3r.sh

Workflow:
1. Enter scope domains
2. Select modules
3. Enter target
4. Run recon
5. Review outputs

---

# 📦 Output Files

hunt3r_clean.txt — discovered subdomains  
hunt3r_nmap.txt — service/port scan results  
HUNT3R_REPORT.md — generated report  

---

# ⚖️ Legal & Ethical Use

This tool is intended only for authorized security testing.

Allowed:
- VDP programs (HackerOne, Bugcrowd, etc.)
- Explicit permission testing
- Owned infrastructure

Not allowed:
- Unauthorized scanning
- Exploitation or disruption
- Out-of-scope targets

Users are responsible for compliance with all laws and program rules.

---

# 📌 Disclaimer

This tool is provided for educational and defensive security research purposes only. The author assumes no liability for misuse or damages caused by this tool.
