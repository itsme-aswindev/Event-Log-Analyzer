# 📋 PowerShell Detailed Log Analyzer

This PowerShell script is designed to remotely gather and analyze Windows Event Logs from a list of servers. It filters logs based on predefined Event IDs and compiles the results into a comprehensive report for diagnostics, auditing, or incident response purposes.

---

## 📌 Features

- 🔍 Scans multiple remote servers listed in `servers.txt`
- 🧠 Filters logs based on specific **Event IDs** defined within the script
- 📅 Customizable **log time range** (e.g., past X days or a specific date window)
- 📂 Consolidated log output for ease of analysis
- 📈 Ideal for:
  - Root cause analysis
  - Security auditing
  - Performance troubleshooting

---

## 📁 Input Files

### `servers.txt`

Plain text file containing the list of target server hostnames or IP addresses (one per line):

