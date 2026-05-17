#!/bin/bash

# =====================================================
# HUNT3R ENGINE v7.2 - STABLE MAC EDITION
# =====================================================

VERSION="v7.2 Stable Build"

# ==============================
# LOGO
# ==============================
echo " ____________________________________________________ "
echo "|                                                    |"
echo "|   ██   ██  ██   ██  ████  ██████  ██████  █████    |"
echo "|   ██   ██  ██   ██  ██  ██  ██     ██      ██  ██   |"
echo "|   ███████  ██   ██  ████   ████   ██████   █████    |"
echo "|   ██   ██  ██   ██  ██  ██  ██        ██   ██ ██   |"
echo "|   ██   ██   █████   ██  ██  ██████  ██████  ██  ██  |"
echo "|                                                    |"
echo "|            -- HUNT3R RECON ENGINE --              |"
echo "|         stable • safe • scoped • mac-ready        |"
echo "|____________________________________________________|"
echo ""

echo "[ Version: $VERSION ]"
echo ""

# ==============================
# CHECK DEPENDENCIES
# ==============================
echo "[+] Checking tools..."

SUBLIST3R="$HOME/Sublist3r/sublist3r.py"
DIRSEARCH="$HOME/Sublist3r/dirsearch/dirsearch.py"

if command -v nmap >/dev/null 2>&1; then
    echo "[✓] Nmap found"
else
    echo "[✗] Nmap missing (brew install nmap)"
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

echo ""
echo "=============================="
echo ""

# ==============================
# SCOPE INPUT
# ==============================
echo "[+] Enter scope (blank line to finish)"
> scope.txt

while true; do
    read -p "scope> " s
    [ -z "$s" ] && break
    echo "$s" >> scope.txt
done

echo ""
echo "[+] Scope loaded:"
cat scope.txt
echo ""

# ==============================
# TARGET INPUT
# ==============================
read -p "Target domain: " TARGET

if [ -z "$TARGET" ]; then
    echo "[!] No target set"
    exit 1
fi

# ==============================
# SCOPE CHECK
# ==============================
is_in_scope() {
    while read -r d; do
        [[ "$TARGET" == *"$d"* ]] && return 0
    done < scope.txt
    return 1
}

if ! is_in_scope "$TARGET"; then
    echo "[⛔] OUT OF SCOPE - STOPPED"
    exit 1
fi

echo ""
echo "[+] Target approved"
echo ""

# ==============================
# SUBLIST3R
# ==============================
if [ -f "$SUBLIST3R" ]; then
    echo "[+] Running Sublist3r..."

    python3 "$SUBLIST3R" -d "$TARGET" -o hunt3r_raw.txt >/dev/null 2>&1

    if [ -f hunt3r_raw.txt ]; then
        sort -u hunt3r_raw.txt > hunt3r_clean.txt
        echo "[✓] Subdomains saved"
    else
        echo "[!] No subdomains found"
    fi
else
    echo "[SKIP] Sublist3r not installed"
fi

echo ""

# ==============================
# DIRSEARCH
# ==============================
if [ -f "$DIRSEARCH" ] && [ -f hunt3r_clean.txt ]; then
    echo "[+] Running Dirsearch..."

    head -n 3 hunt3r_clean.txt | while read sub; do
        echo "[→] https://$sub"

        python3 "$DIRSEARCH" \
        -u "https://$sub" -e php,html,txt -t 10
    done
else
    echo "[SKIP] Dirsearch not available or no subdomains"
fi

echo ""

# ==============================
# NMAP (ALWAYS RUNS)
# ==============================
if command -v nmap >/dev/null 2>&1; then
    echo "[+] Running Nmap..."

    IP=$(dig +short "$TARGET" | tail -n1)
    [ -z "$IP" ] && IP="$TARGET"

    nmap -sV --top-50-ports "$IP" -oN hunt3r_nmap.txt

    echo "[✓] Nmap saved to hunt3r_nmap.txt"
else
    echo "[!] Nmap missing"
fi

echo ""
echo "================ DONE ================"
echo "[✓] Hunt3r complete"
echo "======================================"
