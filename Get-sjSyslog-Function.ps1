function Get-sjSyslog {
  param (
    [string]$SyslogPath = '/var/log/syslog'
  )
  
  # Define regex patterns
  $regexSystemd = @(
    '^',
    '(?<Date>\w{3}\s+\d+\s+\d{2}:\d{2}:\d{2})',
    '\s+',
    '(?<Host>\S+)',
    '\s+',
    '(?<Process>\w+)',
    '\[',
    '(?<PID>\d+)',
    '\]:',
    '\s+',
    '(?<Message>.+)',
    '$'
  ) -join ''
  
  $regexDashM = @(
    '^',
    '(?<Date>\w{3}\s+\d+\s+\d{2}:\d{2}:\d{2})',
    '\s+',
    '(?<Host>\S+)',
    '\s+',
    '-m:',
    '\s+',
    '(?<Message>.+)',
    '$'
  ) -join ''
  
  $regexKernel = @(
    '^',
    '(?<Date>\w{3}\s+\d+\s+\d{2}:\d{2}:\d{2})', # Match date format
    '\s+',
    '(?<Host>\S+)',
    '\s+',
    'kernel:',
    '\s+\[\s*',
    '(?<PID>[\d\.]+)',
    '\]\s+',
    '(?<Message>.+)',
    '$'
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
Get-sjSyslog