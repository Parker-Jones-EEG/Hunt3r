#!/bin/bash

# ==============================
# COLORS
# ==============================
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
NC="\033[0m"

SESSION_FILE="hunt3r_session.txt"
LOG_FILE="hunt3r_log.txt"

# ==============================
# INIT
# ==============================
touch scope.txt
touch "$LOG_FILE"

TARGET=""
QUEUE=()

RUN_SUBLIST3R=1
RUN_DIRSEARCH=1
RUN_NMAP=1

# ==============================
# LOG SYSTEM
# ==============================
log() {
    echo -e "${GREEN}[+] $1${NC}"
    echo "[+] $1" >> "$LOG_FILE"
}

# ==============================
# DASHBOARD
# ==============================
render() {
    echo -e "${BLUE}"
    echo "===================================================="
    echo "             HUNT3R v7.5 - RECON OS"
    echo "===================================================="
    echo -e "${NC}"

    echo -e "${YELLOW}[ ACTIVE TARGET ]${NC} $TARGET"
    echo ""

    echo -e "${YELLOW}[ QUEUE ]${NC}"
    for i in "${QUEUE[@]}"; do
        echo " - $i"
    done
    [ ${#QUEUE[@]} -eq 0 ] && echo " (empty)"
    echo ""

    echo -e "${YELLOW}[ SCOPE ]${NC}"
    cat scope.txt
    echo ""

    echo -e "${YELLOW}[ MODULES ]${NC}"
    echo " [$( [ $RUN_SUBLIST3R -eq 1 ] && echo "X" || echo " " )] Sublist3r"
    echo " [$( [ $RUN_DIRSEARCH -eq 1 ] && echo "X" || echo " " )] Dirsearch"
    echo " [$( [ $RUN_NMAP -eq 1 ] && echo "X" || echo " " )] Nmap"
    echo ""

    echo -e "${YELLOW}[ COMMANDS ]${NC}"
    echo " s = set scope"
    echo " t = set target"
    echo " a = add target to queue"
    echo " n = next target from queue"
    echo " 1/2/3 = toggle modules"
    echo " r = run scan"
    echo " l = view logs"
    echo " q = quit"
    echo ""

    echo -e "${BLUE}====================================================${NC}"
    echo ""
}

# ==============================
# SCOPE
# ==============================
set_scope() {
    > scope.txt
    echo "[+] Enter scope (empty line ends)"
    while true; do
        read -p "scope> " s
        [ -z "$s" ] && break
        echo "$s" >> scope.txt
    done
}

# ==============================
# TARGET
# ==============================
set_target() {
    read -p "Target: " TARGET
}

# ==============================
# QUEUE SYSTEM
# ==============================
add_queue() {
    [ -z "$TARGET" ] && return
    QUEUE+=("$TARGET")
    log "Added $TARGET to queue"
}

next_target() {
    TARGET="${QUEUE[0]}"
    QUEUE=("${QUEUE[@]:1}")
    log "Switched to $TARGET"
}

# ==============================
# SCAN (MANUAL CONTROL ONLY)
# ==============================
run_scan() {

    if [ -z "$TARGET" ]; then
        log "No target selected"
        return
    fi

    # scope check
    while read -r d; do
        [[ "$TARGET" == *"$d"* ]] || continue
    done < scope.txt

    > hunt3r_clean.txt
    > hunt3r_nmap.txt

    log "Starting scan on $TARGET"

    if [ $RUN_SUBLIST3R -eq 1 ]; then
        log "Sublist3r running"
        python3 ~/Sublist3r/sublist3r.py -d "$TARGET" -o raw.txt > /dev/null 2>&1
        sort -u raw.txt > hunt3r_clean.txt
    fi

    if [ $RUN_DIRSEARCH -eq 1 ]; then
        log "Dirsearch running"
        head -n 2 hunt3r_clean.txt | while read s; do
            python3 ~/Sublist3r/dirsearch/dirsearch.py \
            -u "https://$s" -e php,html,txt -t 10
        done
    fi

    if [ $RUN_NMAP -eq 1 ]; then
        log "Nmap running"
        IP=$(dig +short "$TARGET" | tail -n1)
        [ -z "$IP" ] && IP="$TARGET"
        nmap -sV --top-50-ports "$IP" -oN hunt3r_nmap.txt
    fi

    log "Scan complete"
}

# ==============================
# LOG VIEW
# ==============================
view_logs() {
    less "$LOG_FILE"
}

# ==============================
# MAIN LOOP
# ==============================
while true; do
    render
    read -p "> " c

    case $c in
        s) set_scope ;;
        t) set_target ;;
        a) add_queue ;;
        n) next_target ;;
        1) RUN_SUBLIST3R=$((1-RUN_SUBLIST3R)) ;;
        2) RUN_DIRSEARCH=$((1-RUN_DIRSEARCH)) ;;
        3) RUN_NMAP=$((1-RUN_NMAP)) ;;
        r) run_scan ;;
        l) view_logs ;;
        q) exit 0 ;;
    esac
done
