<#
  End-of-support check
  CodeFirst Limited - https://www.codefirst.co.uk/tools/end-of-support-check/

  Lists the Windows, SQL Server, .NET and Office versions found on this
  computer and the date each one stops receiving security fixes.

  What it reads:
    - the Windows version
    - the registry keys that record installed SQL Server instances,
      .NET Framework versions and Office
    - the output of "dotnet --list-runtimes", if .NET is installed

  It changes nothing, needs no administrator rights and sends nothing
  anywhere. The only file it writes is the CSV you ask for with -CsvPath.

  Run:   powershell -ExecutionPolicy Bypass -File .\end-of-support-check.ps1
  Save:  powershell -ExecutionPolicy Bypass -File .\end-of-support-check.ps1 -CsvPath .\support-status.csv

  Support dates generated on 2026-10-03 from https://www.codefirst.co.uk/end-of-life/
  Check the vendor's own page before relying on a date for a decision.
#>
param([string]$CsvPath)

$ErrorActionPreference = 'SilentlyContinue'
$today = Get-Date

# Product, the date free security fixes end, and the date any paid extension ends.
$dates = @{
  'sql-2008' = @{ Name = 'SQL Server 2008 and 2008 R2'; End = '2019-07-09'; PaidEnd = '2022-07-12' }
  'sql-2012' = @{ Name = 'SQL Server 2012'; End = '2022-07-12'; PaidEnd = '2025-07-08' }
  'sql-2014' = @{ Name = 'SQL Server 2014'; End = '2024-07-09'; PaidEnd = '2027-07-12' }
  'sql-2016' = @{ Name = 'SQL Server 2016'; End = '2026-07-14'; PaidEnd = '2029-07-17' }
  'sql-2017' = @{ Name = 'SQL Server 2017'; End = '2027-10-12'; PaidEnd = $null }
  'sql-2019' = @{ Name = 'SQL Server 2019'; End = '2030-01-08'; PaidEnd = $null }
  'sql-2022' = @{ Name = 'SQL Server 2022'; End = '2033-01-11'; PaidEnd = $null }
  'sql-2025' = @{ Name = 'SQL Server 2025'; End = '2036-01-06'; PaidEnd = $null }
  'netfx-35' = @{ Name = '.NET Framework 3.5 SP1'; End = '2029-01-09'; PaidEnd = $null }
  'netfx-40' = @{ Name = '.NET Framework 4.0, 4.5 and 4.5.1'; End = '2016-01-12'; PaidEnd = $null }
  'netfx-461' = @{ Name = '.NET Framework 4.5.2, 4.6 and 4.6.1'; End = '2022-04-26'; PaidEnd = $null }
  'netfx-462' = @{ Name = '.NET Framework 4.6.2'; End = '2027-01-12'; PaidEnd = $null }
  'netfx-48' = @{ Name = '.NET Framework 4.7 to 4.8.1'; End = $null; PaidEnd = $null }
  'netcore-21' = @{ Name = '.NET Core 2.1'; End = '2021-08-21'; PaidEnd = $null }
  'netcore-31' = @{ Name = '.NET Core 3.1'; End = '2022-12-13'; PaidEnd = $null }
  'net-5' = @{ Name = '.NET 5'; End = '2022-05-10'; PaidEnd = $null }
  'net-6' = @{ Name = '.NET 6'; End = '2024-11-12'; PaidEnd = $null }
  'net-7' = @{ Name = '.NET 7'; End = '2024-05-14'; PaidEnd = $null }
  'net-8' = @{ Name = '.NET 8'; End = '2026-11-10'; PaidEnd = $null }
  'net-9' = @{ Name = '.NET 9'; End = '2026-11-10'; PaidEnd = $null }
  'net-10' = @{ Name = '.NET 10'; End = '2028-11-14'; PaidEnd = $null }
  'ws-2003' = @{ Name = 'Windows Server 2003'; End = '2015-07-14'; PaidEnd = $null }
  'ws-2008' = @{ Name = 'Windows Server 2008 and 2008 R2'; End = '2020-01-14'; PaidEnd = '2023-01-10' }
  'ws-2012' = @{ Name = 'Windows Server 2012 and 2012 R2'; End = '2023-10-10'; PaidEnd = '2026-10-13' }
  'ws-2016' = @{ Name = 'Windows Server 2016'; End = '2027-01-12'; PaidEnd = '2030-01-12' }
  'ws-2019' = @{ Name = 'Windows Server 2019'; End = '2029-01-09'; PaidEnd = $null }
  'ws-2022' = @{ Name = 'Windows Server 2022'; End = '2031-10-14'; PaidEnd = $null }
  'ws-2025' = @{ Name = 'Windows Server 2025'; End = '2034-11-14'; PaidEnd = $null }
  'access-2010' = @{ Name = 'Office and Access 2010'; End = '2020-10-13'; PaidEnd = $null }
  'access-2013' = @{ Name = 'Office and Access 2013'; End = '2023-04-11'; PaidEnd = $null }
  'access-2016' = @{ Name = 'Office and Access 2016'; End = '2025-10-14'; PaidEnd = $null }
  'access-2019' = @{ Name = 'Office and Access 2019'; End = '2025-10-14'; PaidEnd = $null }
  'access-2021' = @{ Name = 'Office and Access 2021'; End = '2026-10-13'; PaidEnd = $null }
  'access-2024' = @{ Name = 'Office and Access 2024'; End = '2029-10-09'; PaidEnd = $null }
}

$rows = New-Object System.Collections.ArrayList

function Add-Row([string]$Component, [string]$Found, [string]$Id) {
  $product = ''
  $ends = ''
  $paid = ''
  $status = 'Not tracked'
  if ($Id -and $dates.ContainsKey($Id)) {
    $d = $dates[$Id]
    $product = $d.Name
    if ($d.PaidEnd) { $paid = ([datetime]$d.PaidEnd).ToString('d MMM yyyy') }
    if ($d.End) {
      $end = [datetime]$d.End
      $ends = $end.ToString('d MMM yyyy')
      if ($end -lt $today) { $status = 'OUT OF SUPPORT' }
      elseif ($end -lt $today.AddDays(365)) { $status = 'Ends within a year' }
      else { $status = 'Supported' }
    }
    else {
      $ends = 'No end date announced'
      $status = 'Supported'
    }
  }
  [void]$rows.Add([pscustomobject]@{
      Component          = $Component
      Found              = $Found
      Product            = $product
      'Security fixes end' = $ends
      'Paid extension to' = $paid
      Status             = $status
    })
}

# ---- Windows ----
$os = Get-CimInstance Win32_OperatingSystem
if (-not $os) { $os = Get-WmiObject Win32_OperatingSystem }
if ($os) {
  $build = [int]$os.BuildNumber
  $found = ('{0}, build {1}' -f $os.Caption.Trim(), $build)
  if ([int]$os.ProductType -eq 1) {
    Add-Row 'Windows' ($found + ' (desktop edition; this check covers server versions)') ''
  }
  else {
    $id = ''
    if ($build -ge 26100) { $id = 'ws-2025' }
    elseif ($build -ge 20348) { $id = 'ws-2022' }
    elseif ($build -ge 17763) { $id = 'ws-2019' }
    elseif ($build -ge 14393) { $id = 'ws-2016' }
    elseif ($build -ge 9200) { $id = 'ws-2012' }
    elseif ($build -ge 6001) { $id = 'ws-2008' }
    elseif ($build -ge 3790) { $id = 'ws-2003' }
    Add-Row 'Windows Server' $found $id
  }
}

# ---- SQL Server (every installed instance, including Express) ----
$sqlMajor = @{ 10 = 'sql-2008'; 11 = 'sql-2012'; 12 = 'sql-2014'; 13 = 'sql-2016'; 14 = 'sql-2017'; 15 = 'sql-2019'; 16 = 'sql-2022'; 17 = 'sql-2025' }
$seen = @{}
foreach ($root in 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Microsoft SQL Server') {
  $names = Get-ItemProperty ($root + '\Instance Names\SQL')
  if (-not $names) { continue }
  foreach ($p in $names.PSObject.Properties) {
    if ('PSPath', 'PSParentPath', 'PSChildName', 'PSDrive', 'PSProvider' -contains $p.Name) { continue }
    $instanceId = [string]$p.Value
    if ($seen.ContainsKey($instanceId)) { continue }
    $seen[$instanceId] = $true
    $setup = Get-ItemProperty ($root + '\' + $instanceId + '\Setup')
    if (-not $setup) { continue }
    $major = 0
    if ($setup.Version) { $major = [int]($setup.Version.Split('.')[0]) }
    Add-Row 'SQL Server' ('Instance {0}: {1}, version {2}' -f $p.Name, $setup.Edition, $setup.Version) $sqlMajor[$major]
  }
}

# ---- .NET Framework ----
$v35 = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5'
if ($v35 -and $v35.Install -eq 1) { Add-Row '.NET Framework' ('3.5 ({0})' -f $v35.Version) 'netfx-35' }

$v4 = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
if ($v4 -and $v4.Release) {
  $r = [int]$v4.Release
  $name = '4.5'; $id = 'netfx-40'
  if ($r -ge 533320) { $name = '4.8.1'; $id = 'netfx-48' }
  elseif ($r -ge 528040) { $name = '4.8'; $id = 'netfx-48' }
  elseif ($r -ge 461808) { $name = '4.7.2'; $id = 'netfx-48' }
  elseif ($r -ge 461308) { $name = '4.7.1'; $id = 'netfx-48' }
  elseif ($r -ge 460798) { $name = '4.7'; $id = 'netfx-48' }
  elseif ($r -ge 394802) { $name = '4.6.2'; $id = 'netfx-462' }
  elseif ($r -ge 394254) { $name = '4.6.1'; $id = 'netfx-461' }
  elseif ($r -ge 393295) { $name = '4.6'; $id = 'netfx-461' }
  elseif ($r -ge 379893) { $name = '4.5.2'; $id = 'netfx-461' }
  elseif ($r -ge 378675) { $name = '4.5.1'; $id = 'netfx-40' }
  Add-Row '.NET Framework' ('{0} (release {1})' -f $name, $r) $id
}

# ---- Modern .NET runtimes ----
$dotnet = Get-Command dotnet
if ($dotnet) {
  $netId = @{ '2.1' = 'netcore-21'; '3.1' = 'netcore-31'; '5.0' = 'net-5'; '6.0' = 'net-6'; '7.0' = 'net-7'; '8.0' = 'net-8'; '9.0' = 'net-9'; '10.0' = 'net-10' }
  $runtimes = & dotnet --list-runtimes 2>$null | Where-Object { $_ -like 'Microsoft.NETCore.App *' }
  $newest = @{}
  foreach ($line in $runtimes) {
    $version = ($line -split ' ')[1]
    $parts = $version.Split('.')
    $key = $parts[0] + '.' + $parts[1]
    if (-not $newest.ContainsKey($key) -or ([version]($version -replace '-.*$', '')) -gt ([version]($newest[$key] -replace '-.*$', ''))) { $newest[$key] = $version }
  }
  foreach ($key in ($newest.Keys | Sort-Object { [version]$_ })) {
    Add-Row '.NET runtime' ('.NET {0} (latest installed {1})' -f $key, $newest[$key]) $netId[$key]
  }
}

# ---- Office and Access ----
$c2r = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration'
if ($c2r -and $c2r.ProductReleaseIds) {
  foreach ($product in ($c2r.ProductReleaseIds -split ',')) {
    $id = 'access-2016'
    $label = $product
    if ($product -match 'O365|M365|Microsoft365') { $id = ''; $label = $product + ' (Microsoft 365 subscription, updated continuously)' }
    elseif ($product -match '2024') { $id = 'access-2024' }
    elseif ($product -match '2021') { $id = 'access-2021' }
    elseif ($product -match '2019') { $id = 'access-2019' }
    Add-Row 'Office' ('{0}, version {1}' -f $label, $c2r.VersionToReport) $id
  }
}
else {
  $officeMsi = @{ '14.0' = 'access-2010'; '15.0' = 'access-2013'; '16.0' = 'access-2016' }
  foreach ($v in '14.0', '15.0', '16.0') {
    foreach ($root in 'HKLM:\SOFTWARE\Microsoft\Office', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office') {
      $install = Get-ItemProperty ($root + '\' + $v + '\Common\InstallRoot')
      if ($install -and $install.Path) { Add-Row 'Office' ('Office {0} at {1}' -f $v, $install.Path) $officeMsi[$v]; break }
    }
  }
}

# ---- Report ----
Write-Host ''
Write-Host ('End-of-support check for {0} on {1}' -f $env:COMPUTERNAME, $today.ToString('d MMM yyyy'))
$rows | Format-Table -AutoSize -Wrap | Out-String -Width 220 | Write-Host

$ended = @($rows | Where-Object { $_.Status -eq 'OUT OF SUPPORT' }).Count
$soon = @($rows | Where-Object { $_.Status -eq 'Ends within a year' }).Count
Write-Host ('{0} item(s) out of support, {1} ending within a year, {2} checked.' -f $ended, $soon, $rows.Count)
Write-Host 'This lists what is installed on this computer only. Applications, databases on other servers and anything a supplier hosts are not covered.'
Write-Host 'Dates and what they mean: https://www.codefirst.co.uk/end-of-life/'
Write-Host 'For a second opinion, send this output (not your code or data) to contact@codefirst.co.uk.'

if ($CsvPath) {
  $rows | Export-Csv -Path $CsvPath -NoTypeInformation
  Write-Host ('Saved to {0}' -f $CsvPath)
}
