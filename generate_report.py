import datetime

target = input("Target: ")

with open("HUNT3R_REPORT.md", "w") as f:
    f.write(f"""# Hunt3r Report

Target: {target}
Date: {datetime.datetime.now()}

Files:
- hunt3r_clean.txt
- hunt3r_nmap.txt
""")

print("[+] Report generated")
