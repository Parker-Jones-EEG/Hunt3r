#!/bin/bash

# =====================================================
# HUNT3R ENGINE v7.3 - CLEAN STABLE VDP EDITION
# =====================================================

VERSION="v7.3 Stable VDP Build"

# ==============================
# CLEAN OLD FILES
# ==============================
rm -f scope.txt
rm -f hunt3r_raw.txt
rm -f hunt3r_clean.txt
rm -f hunt3r_nmap.txt
rm -f live.txt

# ==============================
# LOGO
# ==============================
clear

echo " ____________________________________________________ "
echo "|                                                    |"
echo "|   ██   ██  ██   ██  ████  ██████  ██████  █████    |"
echo "|   ██   ██  ██   ██  ██  ██  ██     ██      ██  ██  |"
echo "|   ███████  ██   ██  ████   ████   ██████   █████   |"
echo "|   ██   ██  ██   ██  ██  ██  ██        ██   ██ ██   |"
echo "|   ██   ██   █████   ██  ██  ██████  ██████  ██  ██ |"
echo "|                                                    |"
echo "|            -- HUNT3R RECON ENGINE --               |"
echo "|         stable • safe • scoped • mac-ready         |"
echo "|____________________________________________________|"
echo ""

echo "[ Version: $VERSION ]"
echo ""

# ==============================
# TOOL PATHS
# ==============================
SUBLIST3R="$HOME/tools/Sublist3r/sublist3r.py"
DIRSEARCH="$HOME/tools/dirsearch/dirsearch.py"

# ==============================
# CHECK TOOLS
# ==============================
echo "[+] Checking tools..."
echo ""

if command -v nmap >/dev/null 2>&1; then
    echo "[✓] Nmap found"
else
    echo "[✗] Nmap missing"
fi

if [ -f "$SUBLIST3R" ]; then
    echo "[✓] Sublist3r found"
else
    echo "[✗] Sublist3r missing"
fi

if [ -f "$DIRSEARCH" ]; then
    echo "[✓] Dirsearch found"
else
    echo "[✗] Dirsearch missing"
fi

if command -v httpx >/dev/null 2>&1; then
    echo "[✓] httpx found"
else
    echo "[!] httpx optional but recommended"
fi

echo ""
echo "=============================="
echo ""

# ==============================
# SCOPE INPUT
# ==============================
echo "[+] Enter scope domains"
echo "[+] Press ENTER on blank line to finish"
echo ""

while true; do
    read -p "scope> " s
    [ -z "$s" ] && break
    echo "$s" >> scope.txt
done

echo ""
echo "[+] Loaded Scope:"
cat scope.txt
echo ""

# ==============================
# TARGET INPUT
# ==============================
read -p "Target domain: " TARGET

if [ -z "$TARGET" ]; then
    echo "[!] No target entered"
    exit 1
fi

# ==============================
# SAFE SCOPE CHECK
# ==============================
is_in_scope() {
    while read -r d; do
        [[ "$TARGET" == "$d" || "$TARGET" == *."$d" ]] && return 0
    done < scope.txt

    return 1
}

if ! is_in_scope; then
    echo ""
    echo "[⛔] TARGET OUT OF SCOPE"
    exit 1
fi

echo ""
echo "[✓] Target approved"
echo ""

# ==============================
# SUBDOMAIN ENUM
# ==============================
if [ -f "$SUBLIST3R" ]; then

    echo "[+] Running Sublist3r..."
    echo ""

    python3 "$SUBLIST3R" \
    -d "$TARGET" \
    -o hunt3r_raw.txt >/dev/null 2>&1

    if [ -f hunt3r_raw.txt ]; then

        sort -u hunt3r_raw.txt > hunt3r_clean.txt

        echo "[✓] Subdomains discovered:"
        cat hunt3r_clean.txt

    else
        echo "[!] No subdomains found"
    fi

else
    echo "[SKIP] Sublist3r missing"
fi

echo ""

# ==============================
# LIVE HOST CHECK
# ==============================
if command -v httpx >/dev/null 2>&1 && [ -f hunt3r_clean.txt ]; then

    echo "[+] Probing live hosts..."

    cat hunt3r_clean.txt | httpx -silent > live.txt

    echo ""
    echo "[✓] Live hosts:"
    cat live.txt
    echo ""

fi

# ==============================
# DIRSEARCH
# ==============================
if [ -f "$DIRSEARCH" ]; then

    echo "[+] Starting Dirsearch"
    echo ""

    if [ -f live.txt ]; then
        INPUT_FILE="live.txt"
    else
        INPUT_FILE="hunt3r_clean.txt"
    fi

    echo "[DEBUG] Dirsearch Targets:"
    cat "$INPUT_FILE"
    echo ""

    head -n 3 "$INPUT_FILE" | while read -r sub; do

        [ -z "$sub" ] && continue

        echo "================================="
        echo "[→] Scanning: $sub"
        echo "================================="

        python3 "$DIRSEARCH" \
        -u "$sub" \
        -e php,html,txt \
        -t 5 \
        --random-agent \
        --delay=0.5

        echo ""

    done

else
    echo "[SKIP] Dirsearch missing"
fi

echo ""

# ==============================
# NMAP
# ==============================
if command -v nmap >/dev/null 2>&1; then

    echo "[+] Running safe Nmap scan..."

    IP=$(dig +short "$TARGET" | tail -n1)

    [ -z "$IP" ] && IP="$TARGET"

    echo "[DEBUG] IP: $IP"
    echo ""

    nmap -Pn -T2 --top-ports 20 "$IP" -oN hunt3r_nmap.txt

    echo ""
    echo "[✓] Nmap results saved"

else
    echo "[SKIP] Nmap missing"
fi

echo ""
echo "======================================"
echo "[✓] Hunt3r Recon Complete"
echo "======================================"
