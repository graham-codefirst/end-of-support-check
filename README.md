# End-of-support check

A read-only PowerShell script that lists the Windows, SQL Server, .NET and Office versions on a computer and the date each one stops receiving security fixes.

Example output (abridged):

```
Windows        Windows Server 2016 Standard (build 14393)     Windows Server 2016    12 Jan 2027    Ends within a year
SQL Server     Instance MSSQLSERVER: Standard Edition, 13.0   SQL Server 2016        14 Jul 2026    OUT OF SUPPORT
.NET runtime   .NET 6.0 (latest installed 6.0.11)             .NET 6                 12 Nov 2024    OUT OF SUPPORT
```

## Run it

From the PowerShell Gallery:

```powershell
Install-Script -Name EndOfSupportCheck -Scope CurrentUser
EndOfSupportCheck.ps1
```

Or download [`end-of-support-check.ps1`](end-of-support-check.ps1) and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\end-of-support-check.ps1
powershell -ExecutionPolicy Bypass -File .\end-of-support-check.ps1 -CsvPath .\support-status.csv
```

Works on Windows PowerShell 5.1 and PowerShell 7.

## What it does

- Reads the Windows version, the registry keys that record installed SQL Server instances, .NET Framework versions and Office, and the output of `dotnet --list-runtimes`.
- Changes nothing, needs no administrator rights and sends nothing anywhere. The only file it writes is the CSV you ask for with `-CsvPath`.
- Covers this computer only: applications, databases on other servers and anything a supplier hosts are not included.

## Where the dates come from

The support dates are generated from the end-of-support data behind [codefirst.co.uk/end-of-life](https://www.codefirst.co.uk/end-of-life/), checked against the vendors' lifecycle pages. This repository and the Gallery package are updated automatically whenever a date changes. Check the vendor's own page before relying on a date for a decision.

Maintained by [CodeFirst](https://www.codefirst.co.uk/), a UK company that maintains and modernises business software. Background and an online version: [End-of-support check](https://www.codefirst.co.uk/tools/end-of-support-check/).

## Licence

MIT. See [LICENSE](LICENSE).
