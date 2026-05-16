# 💻 Hunt3r Engine v6.0 — Interactive VDP Recon Framework

Hunt3r is an automated, modular, and multi-layered security reconnaissance framework designed to map an organization's attack surface. Version 6.0 introduces an interactive checkbox interface, letting operators selectively activate modules to remain fully compliant with Vulnerability Disclosure Program (VDP) safe harbor terms.

---

## 🛠️ Chained Infrastructure Modules
1. **Sublist3r** — Multithreaded subdomain enumeration and asset inventory mapping.
2. **Dirsearch** — High-speed web directory crawling and responsive layout analysis.
3. **Nmap** — Core packet routing inspections, fast-track open port audits, and service tracking.
4. **SQLMap** — Parametric SQL Injection validation utilizing tactical user-agent rotation modules.
5. **Metasploit Framework** — Automated network-layer auxiliary weakness and service version profiling.

---

## ⚙️ Interactive Engine Control (New in v6.0)
Version 6.0 features a terminal-based configuration dashboard. Before launching an orchestration pipeline, users can selectively toggle active modules via numerical selections:
* **Safer VDP Profile:** Deactivate SQLMap (Module 4) and Metasploit (Module 5) to run purely passive information-gathering pipelines.
* **Smart Chaining:** Discoveries from early discovery modules are automatically fed downstream into subsequent active port scanners.

---

## 🚀 Installation & System Configuration
To deploy the framework, ensure all system binaries (`nmap`, `sqlmap`, `dirsearch`, `msfconsole`) are accessible within your path environment.

### 1. Set Up Prerequisites & Sublist3r
```bash
# Update repositories and install foundational tool packages
sudo apt update && sudo apt install -y nmap sqlmap dirsearch metasploit-framework git python3 python3-pip

# Clone Sublist3r directly into your user's home folder (Required for path mappings)
git clone https://github.com ~/Sublist3r
pip3 install -r ~/Sublist3r/requirements.txt
```

### 2. Download and Configure Hunt3r
```bash
# Clone this repository
git clone https://github.com
cd Hunt3r

# Grant binary execution privileges to the engine script
chmod +x Hunt3r.sh
```

---

## 🎯 Tactical Execution
Due to deep-layer packet manipulation and core network raw socket management requirements, Hunt3r must be initiated using root system authorization:

```bash
sudo ./Hunt3r.sh
```

---

## 📦 Output Repositories
Upon pipeline completion, structured session logs are exported cleanly back to the home user environment:
* `~/hunt3r_clean.txt` — Unique, sorted active asset subdomain inventory.
* `~/hunt3r_nmap.txt` — Surface fingerprinting scan reports.
* `~/hunt3r_metasploit_log.txt` — System service vulnerability data maps.

---

## ⚖️ Legal Safe Harbor & Ethical Policy
Usage of Hunt3r for attacking infrastructure without explicit prior mutual consent is strictly prohibited. When targeting entities covered under a Vulnerability Disclosure Program (VDP), operators are explicitly advised to configure the runtime scope variables using the module menu to avoid violating rate-limiting terms or triggering defensive application blocks.
