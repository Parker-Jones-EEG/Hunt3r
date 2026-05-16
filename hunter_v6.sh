#!/usr/bin/env bash

# Colors for UI
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default module states (0 = off, 1 = on)
RUN_SUBLIST3R=1
RUN_DIRSEARCH=0
RUN_NMAP=0
RUN_SQLMAP=0
RUN_METASPLOIT=0

show_menu() {
    clear
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${BLUE}               HUNT3R FRAMEWORK                ${NC}"
    echo -e "${BLUE}===============================================${NC}"
    echo -e "Select modules to run (Type number to toggle, 'r' to RUN, 'q' to QUIT):\n"
    
    echo -e "[1] $([ $RUN_SUBLIST3R -eq 1 ] && echo -e "${GREEN}[X] Sublist3r (Subdomain Recon)${NC}" || echo -e "[ ] Sublist3r")"
    echo -e "[2] $([ $RUN_DIRSEARCH -eq 1 ] && echo -e "${GREEN}[X] Dirsearch (Web Crawling)${NC}" || echo -e "[ ] Dirsearch")"
    echo -e "[3] $([ $RUN_NMAP -eq 1 ] && echo -e "${GREEN}[X] Nmap (Port Auditing)${NC}" || echo -e "[ ] Nmap")"
    echo -e "[4] $([ $RUN_SQLMAP -eq 1 ] && echo -e "${RED}[X] SQLMap (SQLi Testing - Loud)${NC}" || echo -e "[ ] SQLMap")"
    echo -e "[5] $([ $RUN_METASPLOIT -eq 1 ] && echo -e "${RED}[X] Metasploit (Exploitation - Heavy)${NC}" || echo -e "[ ] Metasploit")"
    echo ""
}

# Menu loop
while true; do
    show_menu
    read -p "Choice: " choice
    case $choice in
        1) RUN_SUBLIST3R=$((1 - RUN_SUBLIST3R)) ;;
        2) RUN_DIRSEARCH=$((1 - RUN_DIRSEARCH)) ;;
        3) RUN_NMAP=$((1 - RUN_NMAP)) ;;
        4) RUN_SQLMAP=$((1 - RUN_SQLMAP)) ;;
        5) RUN_METASPLOIT=$((1 - RUN_METASPLOIT)) ;;
        r|R) break ;;
        q|Q) echo -e "${RED}Exiting.${NC}"; exit 0 ;;
        *) echo -e "${YELLOW}Invalid option${NC}"; sleep 1 ;;
    esac
done

# Get Target
echo ""
read -p "Enter base target domain (e.g., example.com): " TARGET
if [ -z "$TARGET" ]; then
    echo -e "${RED}Error: Target cannot be empty.${NC}"
    exit 1
fi

OUTPUT_DIR="./hunt3r_results_${TARGET}"
mkdir -p "$OUTPUT_DIR"

# ==========================================
# PIPELINE EXECUTION (Smart Data Chaining)
# ==========================================

# MODULE 1: SUBLIST3R
if [ $RUN_SUBLIST3R -eq 1 ]; then
    echo -e "\n${BLUE}[*] Launching Sublist3r Recon...${NC}"
    python3 ~/Sublist3r/sublist3r.py -d "$TARGET" -o "$OUTPUT_DIR/subdomains.txt"
    TARGET_LIST="$OUTPUT_DIR/subdomains.txt"
else
    # If sublist3r is skipped, use the base domain as the target
    echo "$TARGET" > "$OUTPUT_DIR/base_target.txt"
    TARGET_LIST="$OUTPUT_DIR/base_target.txt"
fi

# MODULE 2: NMAP (Now scans discovered subdomains intelligently)
if [ $RUN_NMAP -eq 1 ]; then
    echo -e "\n${BLUE}[*] Launching Nmap Port Auditing...${NC}"
    if [ -s "$TARGET_LIST" ]; then
        # -sV (Service versions), -T3 (Polite speed for VDPs), -iL (Input list)
        nmap -sV -T3 -F -iL "$TARGET_LIST" -oA "$OUTPUT_DIR/nmap_results"
    else
        echo -e "${YELLOW}[!] No subdomains found to scan.${NC}"
    fi
fi

# MODULE 3: DIRSEARCH
if [ $RUN_DIRSEARCH -eq 1 ]; then
    echo -e "\n${BLUE}[*] Launching Dirsearch Web Crawling...${NC}"
    # Crawls the main domain safely. Added thread limiter for stability.
    dirsearch -u "https://$TARGET" -t 20 --format=plain -o "$OUTPUT_DIR/dirsearch_results.txt"
fi

# MODULE 4: SQLMAP (Only runs if user explicitly verified it)
if [ $RUN_SQLMAP -eq 1 ]; then
    echo -e "\n${RED}[!] WARNING: Launching Active SQLMap Injection Audits...${NC}"
    # --batch automates prompts, --random-agent bypasses basic WAF blocks
    sqlmap -u "https://$TARGET" --batch --random-agent --level=1 --risk=1 --output-dir="$OUTPUT_DIR/sqlmap"
fi

# MODULE 5: METASPLOIT
if [ $RUN_METASPLOIT -eq 1 ]; then
    echo -e "\n${RED}[!] WARNING: Initializing Metasploit Auxiliary Modules...${NC}"
    # Runs a simple auxiliary port/service scanner instead of destructive exploits
    msfconsole -q -x "use auxiliary/scanner/portscan/tcp; set RHOSTS $TARGET; set PORTS 80,443,22,21,8080; run; exit"
fi

echo -e "\n${GREEN}[+] Hunt3r execution finished. Results saved to: $OUTPUT_DIR${NC}"

