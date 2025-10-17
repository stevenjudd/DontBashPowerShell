#region Demo1
# Bash
find ./demo -maxdepth 1 -type f -name '*.conf' -exec cp {} ./demo/backup \;
# PowerShell
Copy-Item ./demo/*.conf ./demo/backup
#endregion

#region Demo2
# bash
Get-Process aux | grep -v grep | grep -i screen | awk '{print $2}' | xargs kill
# PowerShell
Get-Process screen | Stop-Process
#endregion

#region Demo3
# bash
Get-Process aux | grep -v grep | grep -i screen | awk '{print $2}' | xargs -n1 echo kill
# PowerShell
Get-Process screen | Stop-Process -WhatIf

#endregion

#region Demo4
# Bash
find ./demo/certs -name '*.pem' -exec sh -c 'file="{}"; san=$(openssl x509 -in "$file" -noout -text | grep -A1 "Subject Alternative Name" | tail -n +2 | sed "s/ *DNS://g" | tr "\n" ", " | sed "s/, $//"); echo "Name: $(basename "$file")"; echo "SAN: $san"; echo' \;
# PowerShell
Get-ChildItem ./demo/certs/*.pem | Select-Object Name, @{n = 'SAN'; e = { (openssl x509 -in $_ -noout -text | grep -A 1 'Subject Alternative Name' | tail -n +2) -replace '^\s+', '' } }
#endregion

#region Demo5
# Bash
grep -i 'cron' /var/log/syslog
# PowerShell
gc /var/log/syslog | sls cron
#endregion

#region Demo6
# Bash
awk 'BEGIN { OFS=","; print "timestamp","hostname","process","pid","message" }{ timestamp = $1 " " $2 " " $3; hostname = $4; match($0, / ([^[:space:]]+)\[([0-9]+)\]:/, proc); process = proc[1]; pid = proc[2]; sub(/[^[:space:]]+\[[0-9]+\]:[ \t]*/, "", $0); split($0, parts, " "); message = ""; for (i=5; i<=NF; i++) message = message $i " "; gsub(/"/, "\"\"", message); gsub(/^[ \t]+|[ \t]+$/, "", message); print "\"" timestamp "\"", "\"" hostname "\"", "\"" process "\"", "\"" pid "\"", "\"" message "\""}' /var/log/syslog
# PowerShell
Get-Content /var/log/syslog | ForEach-Object { if ($_ -match '^(?<timestamp>\w+ +\d+ +\d{2}:\d{2}:\d{2}) (?<hostname>[^ ]+) (?<process>[^[]+)\[(?<pid>\d+)\]: (?<message>.+)$') { [PSCustomObject]@{ Timestamp = $matches['timestamp']; Hostname = $matches['hostname']; Process = $matches['process']; PID = $matches['pid']; Message = $matches['message'] } } }
#endregion

