function Get-sjSyslog {
  param (
    [string]$SyslogPath = '/var/log/syslog' # Default syslog path
  )
  
  # Define regex patterns
  $regexSystemd = @(
    '^',                      # Start of line
    '(?<Date>\w{3}\s+\d+\s+\d{2}:\d{2}:\d{2})', # Capture date in 'MMM dd HH:mm:ss' format
    '\s+',                    # One or more spaces
    '(?<Host>\S+)',           # Capture hostname (non-space characters)
    '\s+',                    # One or more spaces
    '(?<Process>\w+)',        # Capture process name (word characters)
    '\[',                     # Match literal '['
    '(?<PID>\d+)',            # Capture PID (digits)
    '\]:',                    # Match literal ']:'
    '\s+',                    # One or more spaces
    '(?<Message>.+)',         # Capture the rest of the line as message
    '$'                       # End of line
  ) -join ''
  
  $regexDashM = @(
    '^',                      # Start of line
    '(?<Date>\w{3}\s+\d+\s+\d{2}:\d{2}:\d{2})', # Capture date in 'MMM dd HH:mm:ss' format
    '\s+',                    # One or more spaces
    '(?<Host>\S+)',           # Capture hostname (non-space characters)
    '\s+',                    # One or more spaces
    '-m:',                    # Match literal '-m:'
    '\s+',                    # One or more spaces
    '(?<Message>.+)',         # Capture the rest of the line as message
    '$'                       # End of line
  ) -join ''
  
  $regexKernel = @(
    '^',                      # Start of line
    '(?<Date>\w{3}\s+\d+\s+\d{2}:\d{2}:\d{2})', # Match date format
    '\s+',                    # One or more spaces
    '(?<Host>\S+)',           # Non-space characters for hostname
    '\s+',                    # One or more spaces
    'kernel:',                # Match the literal string 'kernel:'
    '\s+\[\s*',               # Match one or more spaces, then '[', then optional spaces
    '(?<PID>[\d\.]+)',        # Capture PID: one or more digits or dots (for kernel threads)
    '\]\s+',                  # Match ']', then one or more spaces
    '(?<Message>.+)',         # Capture the rest of the line as the message
    '$'                       # End of line
  ) -join ''

  # Define year for date parsing
  $year = (Get-Date).Year

  # Read syslog file
  Get-Content $SyslogPath | ForEach-Object {
    # Get-Content $SyslogPath | Select -first 20 -Skip 55 | ForEach-Object {
    if ($_ -match $regexSystemd) {
      [PSCustomObject]@{
        Date = [datetime]::ParseExact("$($matches['Date']) $year", 'MMM dd HH:mm:ss yyyy', $null)
        Host = $matches['Host']
        Process = $matches['Process']
        PID = [int]$matches['PID']
        Message = $matches['Message']
      }
    } elseif ($_ -match $regexDashM) {
      [PSCustomObject]@{
        Date = [datetime]::ParseExact("$($matches['Date']) $year", 'MMM dd HH:mm:ss yyyy', $null)
        Host = $matches['Host']
        Process = '-m'
        PID = ''
        Message = $matches['Message']
      }
    } elseif ($_ -match $regexKernel) {
      [PSCustomObject]@{
        Date = [datetime]::ParseExact("$($matches['Date']) $year", 'MMM dd HH:mm:ss yyyy', $null)
        Host = $matches['Host']
        Process = 'kernel'
        PID = $matches['PID']
        Message = $matches['Message']
      }
    } else {
      [PSCustomObject]@{
        Date = $null
        Host = $null
        Process = $null
        PID = $null
        Message = $_
      }
    }
  } # End of ForEach-Object
}

# test cases
# Get-sjSyslog