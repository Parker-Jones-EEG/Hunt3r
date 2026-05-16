#!/bin/bash
clear

if [ "$EUID" -ne 0 ]; then
  echo "[!] ERROR: Hunt3r requires raw network sockets."
  echo "[!] Please re-run this script using: sudo ./hunter_v6.sh"
  exit 1
fi

# Character art frame with updated engine version indicator
echo " ____________________________________________________ "
echo "|                                                    |"
echo "|   _   _   _   _   _   _   _____   _____    ____    |"
echo "|  | | | | | | | | | \ | | |_   _| |___  |  |  _ \   |"
echo "|  | |_| | | | | | |  \| |   | |     __| |  | |_) |  |"
echo "|  |  _  | | |_| | | |\  |   | |    |___ |  |  _ <   |"
echo "|  |_| |_|  \___/  |_| \_|   |_|    |____/  |_| \_\  |"
echo "|                                                    |"
echo "|             -- ENGINE AUTOMATION v6.0 --           |"
echo "|____________________________________________________|"
echo ""

# Default module toggle states (0 = off, 1 = on)
RUN_SUBLIST3R=1
RUN_DIRSEARCH=1
RUN_NMAP=1
RUN_SQLMAP=1
RUN_METASPLOIT=1

# Interactive Menu Loop
while true; do
    clear
    echo " ____________________________________________________ "
    echo "|                                                    |"
    echo "|             -- INTERACTIVE MODULES --              |"
    echo "|____________________________________________________|"
    echo "Toggle modules via numbers. Type 'r' to RUN or 'q' to QUIT:"
    echo ""
    echo -e "  1) [$( [ $RUN_SUBLIST3R -eq 1 ] && echo "X" || echo " " )] Step 1: Mapping Subdomains (Sublist3r)"
    echo -e "  2) [$( [ $RUN_DIRSEARCH -eq 1 ] && echo "X" || echo " " )] Step 2: Querying Web Folders (Dirsearch)"
    echo -e "  3) [$( [ $RUN_NMAP -eq 1 ] && echo "X" || echo " " )] Step 3: Fingerprinting Network Services (Nmap)"
    echo -e "  4) [$( [ $RUN_SQLMAP -eq 1 ] && echo "X" || echo " " )] Step 4: Automated SQL Injection Checks (SQLMap)"
    echo -e "  5) [$( [ $RUN_METASPLOIT -eq 1 ] && echo "X" || echo " " )] Step 5: Automating Weakness Tracing (Metasploit)"
    echo ""
    
    read -p "Selection: " choice
    case $choice in
        1) RUN_SUBLIST3R=$((1 - RUN_SUBLIST3R)) ;;
        2) RUN_DIRSEARCH=$((1 - RUN_DIRSEARCH)) ;;
        3) RUN_NMAP=$((1 - RUN_NMAP)) ;;
        4) RUN_SQLMAP=$((1 - RUN_SQLMAP)) ;;
        5) RUN_METASPLOIT=$((1 - RUN_METASPLOIT)) ;;
        r|R) break ;;
        q|Q) echo "[-] Exiting script."; exit 0 ;;
        *) echo "[!] Invalid option. Use numbers 1-5, 'r', or 'q'."; sleep 1 ;;
    esac
done

clear
# Re-display original logo before target selection
echo " ____________________________________________________ "
echo "|                                                    |"
echo "|   _   _   _   _   _   _   _____   _____    ____    |"
echo "|  | | | | | | | | | \ | | |_   _| |___  |  |  _ \   |"
echo "|  | |_| | | | | | |  \| |   | |     __| |  | |_) |  |"
echo "|  |  _  | | |_| | | |\  |   | |    |___ |  |  _ <   |"
echo "|  |_| |_|  \___/  |_| \_|   |_|    |____/  |_| \_\  |"
echo "|                                                    |"
echo "|             -- ENGINE AUTOMATION v6.0 --           |"
echo "|____________________________________________________|"
echo ""

printf "\033[1;32m[💻] Enter Target Domain:\033[0m "
read TARGET

if [ -z "$TARGET" ]; then
    echo "[-] Error: No domain entered. Exiting."
    exit 1
fi

# ====================================================
# PIPELINE EXECUTION
# ====================================================

# Step 1: Mapping Subdomains (Sublist3r)
if [ $RUN_SUBLIST3R -eq 1 ]; then
    echo ""
    echo "[-] Step 1: Mapping Subdomains (Sublist3r)..."
    echo "----------------------------------------------------"
    cd ~/Sublist3r || exit 1
    python3 sublist3r.py -d "$TARGET" -o ~/hunt3r_raw.txt > /dev/null 2>&1

    if [ -f ~/hunt3r_raw.txt ]; then
        grep -v '^$' ~/hunt3r_raw.txt | sort -u > ~/hunt3r_clean.txt
        TOTAL_SUBS=$(wc -l < ~/hunt3r_clean.txt | tr -d ' ')
    else
        TOTAL_SUBS=0
    fi
    echo "[+] Asset Inventory Complete: Found $TOTAL_SUBS targets!"
else
    echo ""
    echo "[-] Step 1: Mapping Subdomains (Sublist3r)... [SKIPPED]"
    # Ensure fallbacks exist if sublist3r was deactivated
    echo "$TARGET" > ~/hunt3r_clean.txt
fi

# Step 2: Querying Web Folders (Dirsearch)
if [ $RUN_DIRSEARCH -eq 1 ]; then
    echo ""
    echo "[-] Step 2: Querying Web Folders (Dirsearch)..."
    echo "----------------------------------------------------"
    cd ~/Sublist3r/dirsearch || exit 1
    head -n 3 ~/hunt3r_clean.txt > ~/hunt3r_queue.txt

    while read -r sub; do
        echo ""
        echo "[⚡] Target Endpoint: https://$sub"
        echo "----------------------------------------------------"
        python3 dirsearch.py -u "https://$sub" -e php,html,json,txt
    done < ~/hunt3r_queue.txt
else
    echo ""
    echo "[-] Step 2: Querying Web Folders (Dirsearch)... [SKIPPED]"
fi

# Step 3: Fingerprinting Network Services (Nmap)
if [ $RUN_NMAP -eq 1 ]; then
    echo ""
    echo "[-] Step 3: Fingerprinting Network Services (Nmap)..."
    echo "----------------------------------------------------"
    IP_ADDR=$(dig +short "$TARGET" | tail -n1)
    if [ -z "$IP_ADDR" ]; then
        IP_ADDR="$TARGET"
    fi
    echo "[⚡] Target IP Resolved: $IP_ADDR"
    nmap -sV --top-ports 100 "$IP_ADDR" -oN ~/hunt3r_nmap.txt
else
    echo ""
    echo "[-] Step 3: Fingerprinting Network Services (Nmap)... [SKIPPED]"
fi

# Step 4: Automated SQL Injection Checks (SQLMap)
if [ $RUN_SQLMAP -eq 1 ]; then
    echo ""
    echo "[-] Step 4: Automated SQL Injection Checks (SQLMap)..."
    echo "----------------------------------------------------"
    TARGET_URL=$(head -n 1 ~/hunt3r_clean.txt)
    echo "[⚡] Probing Web Parameters: https://$TARGET_URL"
    sqlmap -u "https://$TARGET_URL" --batch --random-agent --crawl=2 --level=1 --risk=1 -o
else
    echo ""
    echo "[-] Step 4: Automated SQL Injection Checks (SQLMap)... [SKIPPED]"
fi

# Step 5: Automating Weakness Tracing (Metasploit)
if [ $RUN_METASPLOIT -eq 1 ]; then
    echo ""
    echo "[-] Step 5: Automating Weakness Tracing (Metasploit)..."
    echo "----------------------------------------------------"
    if [ -z "$IP_ADDR" ]; then
        IP_ADDR=$(dig +short "$TARGET" | tail -n1)
        [ -z "$IP_ADDR" ] && IP_ADDR="$TARGET"
    fi
    cat <<EOF > ~/hunt3r_msf.rc
spool ~/hunt3r_metasploit_log.txt
use auxiliary/scanner/portscan/tcp
set RHOSTS $IP_ADDR
set PORTS 21,22,23,25,80,443,445,3389,8080
run
use auxiliary/scanner/http/http_version
set RHOSTS $IP_ADDR
run
exit
EOF

    msfconsole -q -r ~/hunt3r_msf.rc > /dev/null 2>&1
else
    echo ""
    echo "[-] Step 5: Automating Weakness Tracing (Metasploit)... [SKIPPED]"
fi

# Clean up temporary run queues safely
rm -f ~/hunt3r_msf.rc ~/hunt3r_raw.txt ~/hunt3r_queue.txt

echo ""
echo "____________________________________________________"
echo "[✔] Pipeline complete!"
echo "[✔] Subdomains saved to: ~/hunt3r_clean.txt"
[ $RUN_NMAP -eq 1 ] && echo "[✔] Nmap results saved to: ~/hunt3r_nmap.txt"
[ $RUN_METASPLOIT -eq 1 ] && echo "[✔] Metasploit log saved to: ~/hunt3r_metasploit_log.txt"
echo "____________________________________________________"
