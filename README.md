# 💻 Hunt3r Engine v6.0 — Modular Reconnaissance Framework

Hunt3r is a modular security reconnaissance framework designed to help researchers and authorized security teams map and analyze an organization's external attack surface. Version 6.0 introduces an interactive module-selection interface, allowing operators to enable or disable components depending on engagement scope and Vulnerability Disclosure Program (VDP) requirements.

---

# ✨ Features

- Interactive terminal-based module selection
- Modular reconnaissance workflow
- Automated subdomain enumeration
- Directory and asset discovery
- Port and service scanning
- Optional SQL injection testing
- Organized output logging
- VDP-friendly passive scanning configuration

---

# 🛠️ Included Modules

## 1. Sublist3r
Performs multithreaded subdomain enumeration for external asset discovery.

## 2. Dirsearch
Scans for accessible directories, endpoints, and hidden web content.

## 3. Nmap
Performs network discovery, open-port detection, and service fingerprinting.

## 4. SQLMap *(Optional)*
Tests web parameters for potential SQL injection vulnerabilities.

## 5. Metasploit Framework *(Optional)*
Used for auxiliary enumeration and service version analysis.

---

# ⚙️ Interactive Engine Control

Version 6.0 includes an interactive configuration menu that allows users to selectively enable modules before execution.

### Example Use Cases

- **Passive VDP Mode**  
  Run only Sublist3r, Dirsearch, and Nmap for lower-impact reconnaissance.

- **Extended Testing Mode**  
  Enable SQLMap and Metasploit modules during authorized assessments.

- **Automated Workflow Chaining**  
  Results from discovery modules can be passed into later scanning stages automatically.

---

# 🚀 Installation

Ensure the following tools are installed and accessible in your system PATH:

- `nmap`
- `sqlmap`
- `dirsearch`
- `msfconsole`
- `python3`
- `git`

## 1. Install Dependencies

```bash
sudo apt update

sudo apt install -y \
    nmap \
    sqlmap \
    dirsearch \
    metasploit-framework \
    git \
    python3 \
    python3-pip
```

## 2. Install Sublist3r

```bash
git clone https://github.com/aboul3la/Sublist3r.git ~/Sublist3r

pip3 install -r ~/Sublist3r/requirements.txt
```

## 3. Clone Hunt3r

```bash
git clone https://github.com/Parker-Jones-EEG/Hunt3r.git

cd Hunt3r

chmod +x Hunt3r.sh
```

---

# ▶️ Usage

Run the framework with elevated privileges when required by specific scanning modules:

```bash
sudo ./Hunt3r.sh
```

The interactive menu will prompt you to select active modules before execution.

---

# 📦 Output Files

Generated logs and scan results are exported to the user's home directory:

| File | Description |
|---|---|
| `~/hunt3r_clean.txt` | Discovered subdomains and cleaned asset list |
| `~/hunt3r_nmap.txt` | Nmap scan results and service fingerprints |
| `~/hunt3r_metasploit_log.txt` | Auxiliary enumeration output |

---

# ⚖️ Legal & Ethical Use

Hunt3r is intended strictly for authorized security research, defensive testing, and approved Vulnerability Disclosure Programs (VDPs).

Users are responsible for complying with:
- Applicable laws and regulations
- Program scope limitations
- Rate limits and safe-harbor policies
- Written authorization requirements

Unauthorized use against systems you do not own or have permission to test is prohibited.

---

# 📌 Disclaimer

This project is provided for educational and authorized security testing purposes only.

The developers assume no liability for misuse or damages resulting from the use of this software.
