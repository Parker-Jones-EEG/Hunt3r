#!/bin/bash

# =====================================================
# HUNT3R ENGINE v9.0 - STREAMLINED AUTOMATION BUILD
# =====================================================

VERSION="v9.0 Streamlined Auto Recon"

# ==============================
# SAFETY LOCKS
# ==============================
if [ "$EUID" -eq 0 ]; then
    echo "[!] Do NOT run as root/sudo"
    echo "[!] Prevents broken file ownership + tool path issues"
    exit 1
fi

# ==============================
# CLEAN STATE
# ==============================
rm -f scope.txt hunt3r_raw.txt hunt3r_clean.txt hunt3r_nmap.txt live.txt

# ==============================
# LOGO
# ==============================
clear

if command -v figlet >/dev/null 2>&1; then
    figlet HUNT3R
else
    echo "================ HUNT3R ================"
fi

echo ""
echo "Automated Recon Pipeline • VDP Safe Mode"
echo "Version: $VERSION"
echo "========================================="
echo ""

# ==============================
# ARG PARSING (SINGLE COMMAND MODE)
# ==============================
TARGET=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --target)
            TARGET="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

if [ -z "$TARGET" ]; then
    read -p "Target domain: " TARGET
fi

if [ -z "$TARGET" ]; then
    echo "[!] No target provided"
    exit 1
fi

echo "[+] Target: $TARGET"
echo ""

# ==============================
# TOOL DETECTION (ROBUST)
# ==============================
echo "[+] Checking tools..."
echo ""

command -v nmap >/dev/null && echo "[✓] Nmap" || echo "[✗] Missing"
command -v httpx >/dev/null && echo "[✓] httpx" || echo "[!] httpx optional"

SUBLIST3R=$(find ~ -name "sublist3r.py" 2>/dev/null | head -n 1)
DIRSEARCH=$(find ~ -name "dirsearch.py" 2>/dev/null | head -n 1)

[ -n "$SUBLIST3R" ] && echo "[✓] Sublist3r" || echo "[✗] Missing"
[ -n "$DIRSEARCH" ] && echo "[✓] Dirsearch" || echo "[✗] Missing"

echo ""
echo "========================================="
echo ""

# ==============================
# SUBDOMAIN ENUMERATION
# ==============================
if [ -n "$SUBLIST3R" ]; then
    echo "[+] Subdomain enumeration..."
    python3 "$SUBLIST3R" -d "$TARGET" -o hunt3r_raw.txt >/dev/null 2>&1

    if [ -s hunt3r_raw.txt ]; then
        sort -u hunt3r_raw.txt > hunt3r_clean.txt
        echo "[✓] Subdomains found:"
        cat hunt3r_clean.txt
    else
        echo "[!] No subdomains found"
        exit 0
    fi
else
    echo "[!] Sublist3r missing — cannot continue"
    exit 1
fi

echo ""

# ==============================
# LIVE HOST PROBING
# ==============================
if command -v httpx >/dev/null 2>&1; then
    echo "[+] Probing live hosts..."

    # SAFE UNIVERSAL httpx MODE
    cat hunt3r_clean.txt | httpx -silent > live.txt

    echo "[✓] Live hosts:"
    cat live.txt
else
    echo "[SKIP] httpx missing"
    cp hunt3r_clean.txt live.txt
fi

echo ""

# ==============================
# DIRECTORY ENUMERATION
# ==============================
if [ -n "$DIRSEARCH" ]; then

    echo "[+] Directory enumeration..."

    INPUT_FILE="live.txt"
    [ ! -s "$INPUT_FILE" ] && INPUT_FILE="hunt3r_clean.txt"

    head -n 3 "$INPUT_FILE" | while read -r sub; do
        [ -z "$sub" ] && continue

        echo "-----------------------------------"
        echo "[→] Scanning: $sub"
        echo "-----------------------------------"

        python3 "$DIRSEARCH" \
            -u "$sub" \
            -e php,html,txt \
            -t 5 \
            --random-agent \
            --delay=0.5 >/dev/null 2>&1

        echo ""
    done
else
    echo "[SKIP] Dirsearch missing"
fi

echo ""

# ==============================
# SAFE NMAP
# ==============================
if command -v nmap >/dev/null 2>&1; then

    echo "[+] Nmap scan (safe mode)..."

    IP=$(dig +short "$TARGET" | tail -n1)
    [ -z "$IP" ] && IP="$TARGET"

    echo "[DEBUG] IP: $IP"
    echo ""

    nmap -Pn -T2 --top-ports 20 "$IP" -oN hunt3r_nmap.txt >/dev/null 2>&1

    echo "[✓] Nmap complete"
else
    echo "[SKIP] Nmap missing"
fi

echo ""
echo "========================================="
echo "[✓] Hunt3r pipeline complete"
echo "========================================="
