#!/bin/bash

# =====================================================
# HUNT3R ENGINE v7 - SAFE CLI RECON TOOL
# =====================================================

VERSION="v7 GitHub Edition"

# ==============================
# AUTO UPDATE (SAFE)
# ==============================
if [ -d ".git" ]; then
    echo "[+] Checking for updates..."

    git fetch origin main >/dev/null 2>&1

    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/main)

    if [ "$LOCAL" != "$REMOTE" ]; then
        echo "[↑] Update found — pulling latest version..."
        git pull origin main >/dev/null 2>&1
        echo "[✓] Updated. Restarting..."
        exec bash "$0"
        exit
    else
        echo "[✓] Hunt3r is up to date"
    fi
fi

# ==============================
# LOGO
# ==============================
echo " ____________________________________________________ "
echo "|                                                    |"
echo "|   ██   ██  ██   ██  ████  ██████  ██████  █████    |"
echo "|   ██   ██  ██   ██  ██  ██  ██     ██      ██  ██   |"
echo "|   ███████  ██   ██  ████   ████   ██████   █████    |"
echo "|   ██   ██  ██   ██  ██  ██  ██        ██   ██ ██    |"
echo "|   ██   ██   █████   ██  ██  ██████  ██████  ██  ██  |"
echo "|                                                    |"
echo "|            -- HUNT3R RECON ENGINE v7 --            |"
echo "|         safe • scoped • controlled • fast          |"
echo "|____________________________________________________|"
echo ""

echo "[ Version: $VERSION ]"
echo ""

# ==============================
# STARTUP CINEMATIC (CLEAN CLI STYLE)
# ==============================
echo "[+] Initializing Hunt3r Engine..."
sleep 0.4

echo "Loading core modules [■□□□□□□□□□]"
sleep 0.2
echo "Loading core modules [■■■□□□□□□□]"
sleep 0.2
echo "Loading core modules [■■■■■□□□□□]"
sleep 0.2
echo "Loading core modules [■■■■■■■□□□]"
sleep 0.2
echo "Loading core modules [■■■■■■■■■■]"
sleep 0.2

echo ""
echo "[✓] Core system initialized"
echo "[✓] Scope engine ready"
echo "[✓] GitHub sync active"
echo "[✓] Logging enabled"
echo ""

# ==============================
# SCOPE SETUP
# ==============================
echo "[+] Enter scope domains (blank line to finish)"
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
    echo "[⛔] OUT OF SCOPE — BLOCKED"
    exit 1
fi

# ==============================
# MODULES (SAFE ONLY)
# ==============================
RUN_NMAP=1

echo ""
echo "===== MODULES ====="
echo "[1] Nmap service scan : ON"
echo ""

read -p "Run scan? (y/n): " go
[ "$go" != "y" ] && exit 0

# ==============================
# RECON EXECUTION
# ==============================
echo ""
echo "[+] Starting recon on $TARGET"
echo ""

IP=$(dig +short "$TARGET" | tail -n1)
[ -z "$IP" ] && IP="$TARGET"

echo "[+] Target IP: $IP"
echo ""

# ==============================
# SAFE NMAP SCAN
# ==============================
echo "[+] Running Nmap scan..."
nmap -sV --top-50-ports "$IP" -oN hunt3r_nmap.txt

# ==============================
# FINISH
# ==============================
echo ""
echo "================ DONE ================"
echo "[✓] Results saved: hunt3r_nmap.txt"
echo "[✓] Scope validated"
echo "======================================"
