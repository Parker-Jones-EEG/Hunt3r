#!/bin/bash

# =====================================================
# HUNT3R ENGINE v8.0 - SINGLE COMMAND EDITION
# =====================================================

VERSION="v8.0 One-Line Target Build"

# ==============================
# CLEAN OUTPUT FILES
# ==============================
rm -f scope.txt hunt3r_raw.txt hunt3r_clean.txt hunt3r_nmap.txt live.txt

# ==============================
# PARSE ARGUMENTS
# ==============================
TARGET=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --target)
            TARGET="$2"
            shift
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# ==============================
# LOGO v2 (CLEAN + MODERN)
# ==============================
clear
echo ""
echo "====================================================="
echo ""
echo "   ██╗  ██╗██╗   ██╗███╗   ██╗████████╗██████╗ ██████╗ "
echo "   ██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔══██╗██╔══██╗"
echo "   ███████║██║   ██║██╔██╗ ██║   ██║   ██████╔╝██████╔╝"
echo "   ██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══██╗██╔══██╗"
echo "   ██║  ██║╚██████╔╝██║ ╚████║   ██║   ██║  ██║██║  ██║"
echo "   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝"
echo ""
echo "            H U N T 3 R   R E C O N   E N G I N E"
echo "      passive • scoped • fast • VDP-friendly toolkit"
echo ""
echo "====================================================="
echo "[ Version: $VERSION ]"
echo ""

# ==============================
# TOOL AUTO-DETECT
# ==============================
SUBLIST3R=$(find ~ -name "sublist3r.py" 2>/dev/null | head -n 1)
DIRSEARCH=$(find ~ -name "dirsearch.py" 2>/dev/null | head -n 1)

echo "[+] Checking tools..."
echo ""

command -v nmap >/dev/null && echo "[✓] Nmap" || echo "[✗] Nmap missing"
command -v httpx >/dev/null && echo "[✓] httpx" || echo "[!] httpx optional"

[ -n "$SUBLIST3R" ] && echo "[✓] Sublist3r found" || echo "[✗] Sublist3r missing"
[ -n "$DIRSEARCH" ] && echo "[✓] Dirsearch found" || echo "[✗] Dirsearch missing"

echo ""
echo "=============================="
echo ""

# ==============================
# INTERACTIVE FALLBACK
# ==============================
if [ -z "$TARGET" ]; then
    read -p "Target domain (--target example.com): " TARGET
fi

if [ -z "$TARGET" ]; then
    echo "[!] No target provided"
    exit 1
fi

echo "[+] Target: $TARGET"
echo ""

# ==============================
# SUBDOMAIN ENUM
# ==============================
if [ -n "$SUBLIST3R" ]; then
    echo "[+] Subdomain enumeration..."

    python3 "$SUBLIST3R" -d "$TARGET" -o hunt3r_raw.txt >/dev/null 2>&1

    if [ -f hunt3r_raw.txt ]; then
        sort -u hunt3r_raw.txt > hunt3r_clean.txt
        echo "[✓] Subdomains:"
        cat hunt3r_clean.txt
    fi
else
    echo "[SKIP] Sublist3r missing"
fi

echo ""

# ==============================
# LIVE HOSTS (httpx)
# ==============================
if command -v httpx >/dev/null 2>&1 && [ -f hunt3r_clean.txt ]; then
    echo "[+] Checking live hosts..."
    cat hunt3r_clean.txt | httpx -silent > live.txt

    echo "[✓] Live hosts:"
    cat live.txt
fi

echo ""

# ==============================
# DIRSEARCH
# ==============================
if [ -n "$DIRSEARCH" ]; then

    INPUT_FILE="hunt3r_clean.txt"
    [ -f live.txt ] && INPUT_FILE="live.txt"

    echo "[+] Directory scan targets:"
    cat "$INPUT_FILE"
    echo ""

    head -n 3 "$INPUT_FILE" | while read -r sub; do
        [ -z "$sub" ] && continue

        echo "---------------------------------"
        echo "[→] Scanning: $sub"
        echo "---------------------------------"

        python3 "$DIRSEARCH" \
        -u "$sub" \
        -e php,html,txt \
        -t 5 \
        --random-agent \
        --delay=0.5
    done

else
    echo "[SKIP] Dirsearch missing"
fi

echo ""

# ==============================
# NMAP (SAFE MODE)
# ==============================
if command -v nmap >/dev/null 2>&1; then

    echo "[+] Nmap scan (safe mode)..."

    IP=$(dig +short "$TARGET" | tail -n1)
    [ -z "$IP" ] && IP="$TARGET"

    echo "[DEBUG] IP: $IP"
    echo ""

    nmap -Pn -T2 --top-ports 20 "$IP" -oN hunt3r_nmap.txt

    echo "[✓] Nmap saved"

fi

echo ""
echo "====================================================="
echo "[✓] Hunt3r finished"
echo "====================================================="echo ""

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
