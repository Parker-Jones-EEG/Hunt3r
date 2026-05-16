#!/bin/bash
clear

# ==============================
# ROOT CHECK
# ==============================
if [ "$EUID" -ne 0 ]; then
  echo "[!] Run with sudo for network scanning"
  exit 1
fi

# ==============================
# LOGO (UNCHANGED)
# ==============================
echo " ____________________________________________________ "
echo "|                                                    |"
echo "|   _   _   _   _   _   _   _____   _____    ____    |"
echo "|  | | | | | | | | | \ | | |_   _| |___  |  |  _ \   |"
echo "|  | |_| | | | | | |  \| |   | |     __| |  | |_) |  |"
echo "|  |  _  | | |_| | | |\  |   | |    |___ |  |  _ <   |"
echo "|  |_| |_|  \___/  |_| \_|   |_|    |____/  |_| \_\  |"
echo "|                                                    |"
echo "|             -- ENGINE AUTOMATION v6.3 --           |"
echo "|____________________________________________________|"
echo ""

# ==============================
# AUTO SCOPE INPUT
# ==============================
echo "[+] Enter allowed scope domains (one per line)"
echo "[+] Press ENTER on empty line to finish"
echo ""

> scope.txt

while true; do
    read -p "scope> " line
    [ -z "$line" ] && break
    echo "$line" >> scope.txt
done

echo ""
echo "[+] Scope loaded:"
cat scope.txt
echo ""

# ==============================
# SCOPE CHECK
# ==============================
is_in_scope() {
    while read -r d; do
        [[ "$1" == *"$d"* ]] && return 0
    done < scope.txt
    return 1
}

# ==============================
# MODULE MENU
# ==============================
RUN_SUBLIST3R=1
RUN_DIRSEARCH=1
RUN_NMAP=1

while true; do
    clear
    echo "===== HUNT3R SAFE RECON ====="
    echo ""
    echo "1) Sublist3r   [$RUN_SUBLIST3R]"
    echo "2) Dirsearch   [$RUN_DIRSEARCH]"
    echo "3) Nmap        [$RUN_NMAP]"
    echo ""
    echo "r = run | q = quit"
    read choice

    case $choice in
        1) RUN_SUBLIST3R=$((1-RUN_SUBLIST3R)) ;;
        2) RUN_DIRSEARCH=$((1-RUN_DIRSEARCH)) ;;
        3) RUN_NMAP=$((1-RUN_NMAP)) ;;
        r) break ;;
        q) exit 0 ;;
    esac
done

# ==============================
# TARGET INPUT
# ==============================
read -p "Target domain: " TARGET

# ==============================
# SCOPE ENFORCEMENT
# ==============================
if ! is_in_scope "$TARGET"; then
    echo "[⛔] OUT OF SCOPE - BLOCKED"
    exit 1
fi

# ==============================
# OUTPUT FILES
# ==============================
> hunt3r_clean.txt
> hunt3r_nmap.txt

# ==============================
# SUBDOMAIN ENUM
# ==============================
if [ $RUN_SUBLIST3R -eq 1 ]; then
    echo "[+] Running Sublist3r..."
    python3 ~/Sublist3r/sublist3r.py -d "$TARGET" -o raw.txt > /dev/null 2>&1
    sort -u raw.txt > hunt3r_clean.txt
else
    echo "$TARGET" > hunt3r_clean.txt
fi

# ==============================
# DIRSEARCH (LIGHT MODE)
# ==============================
if [ $RUN_DIRSEARCH -eq 1 ]; then
    echo "[+] Running Dirsearch (light scan)..."

    head -n 3 hunt3r_clean.txt | while read sub; do
        echo "[*] https://$sub"
        python3 ~/Sublist3r/dirsearch/dirsearch.py \
        -u "https://$sub" -e php,html,json,txt -t 10
    done
fi

# ==============================
# NMAP SAFE SCAN
# ==============================
if [ $RUN_NMAP -eq 1 ]; then
    echo "[+] Running Nmap safe scan..."

    IP=$(dig +short "$TARGET" | tail -n1)
    [ -z "$IP" ] && IP="$TARGET"

    nmap -sV --top-50-ports "$IP" -oN hunt3r_nmap.txt
fi

# ==============================
# CLEANUP
# ==============================
rm -f raw.txt

echo ""
echo "================ DONE ================"
echo "[+] Subdomains: hunt3r_clean.txt"
echo "[+] Nmap: hunt3r_nmap.txt"
echo "======================================"

# ==============================
# REPORT OPTION
# ==============================
echo "[?] Generate report? (y/n)"
read gen

if [ "$gen" == "y" ]; then
    python3 generate_report.py
fi
