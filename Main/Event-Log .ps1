<#
    PowerShell script to check reboot, shutdown, or power outage events on remote servers.
    Outputs a detailed, styled HTML report.
#>

# Get the location of the current script and define paths
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ServersFile = Join-Path $ScriptPath 'servers.txt'
$OutputFile = Join-Path $ScriptPath 'Server_Log_Report.html'

# Check if servers.txt exists
if (-not (Test-Path $ServersFile)) {
    Write-Host "Error: servers.txt not found in script location." -ForegroundColor Red
    exit
}

# Read server names from servers.txt
$Servers = Get-Content $ServersFile

# Initialize an empty array to store results
$Results = New-Object System.Collections.Generic.List[PSCustomObject]

# Function to query events
function Get-ServerEvents {
    param (
        [string]$Server
    )

    try {
        Write-Host "Querying events on $Server..." -ForegroundColor Cyan

        # Query Event Logs for shutdown, reboot, or unexpected power loss events
        $Events = Get-WinEvent -ComputerName $Server -FilterHashtable @{
            LogName = @('System', 'Security', 'Application') 
            Id = @(1000, 1069, 1135, 1205, 1001, 6005, 6006, 6008, 41, 1074, 6009, 1076, 6013)
        } | Select-Object -Property TimeCreated, Id, Message

        if ($Events) {
            foreach ($Event in $Events) {
                $Results.Add([PSCustomObject]@{
                    Server      = $Server
                    EventTime   = $Event.TimeCreated
                    EventID     = $Event.Id
                    Description = ($Event.Message -replace '\r|\n', ' ')
                })
            }
        } else {
            $Results.Add([PSCustomObject]@{
                Server      = $Server
                EventTime   = "No Events Found"
                EventID     = "N/A"
                Description = "No relevant events in the System log."
            })
        }
    } catch {
        Write-Host "Error retrieving events from $Server : $_" -ForegroundColor Red
        $Results.Add([PSCustomObject]@{
            Server      = $Server
            EventTime   = "Error"
            EventID     = "Error"
            Description = $_.Exception.Message
        })
    }
}

# Process each server
foreach ($Server in $Servers) {
    Write-Host "Checking events on $Server..." -ForegroundColor Yellow
    Get-ServerEvents -Server $Server
}

# Generate the HTML report
$HTML = @"
<!DOCTYPE html>
<html>
<head>
    <title>Server Reboot Report</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; color: #333; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        tr:hover { background-color: #ddd; }
        caption { font-size: 1.5em; margin: 10px; }
    </style>
</head>
<body>
    <center><h1>Detailed Server Log Report</h1></center>
    <table>
        <caption>Event Details</caption>
        <thead>
            <tr>
                <th>Server</th>
                <th>Event Time</th>
                <th>Event ID</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
"@

# Add rows to the HTML table
foreach ($Result in $Results) {
    $HTML += "<tr>"
    $HTML += "<td>$($Result.Server)</td>"
    $HTML += "<td>$($Result.EventTime)</td>"
    $HTML += "<td>$($Result.EventID)</td>"
    $HTML += "<td>$($Result.Description)</td>"
    $HTML += "</tr>"
}

$HTML += @"
        </tbody>
    </table>
</body>
<footer><center><p>This is an Automated Report Created and Managed by Team. </p></center></footer>
</html>
"@

# Save the HTML report
$HTML | Out-File -FilePath $OutputFile -Encoding UTF8
Write-Host "Report generated at: $OutputFile" -ForegroundColor Green
