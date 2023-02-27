:: If new PowerShell is not installed then pwsh command doesn't exist
:: Old PowerShell has bugged -File argument
set location=%~dp0\example.ps1
pwsh -Command "Start-Process -Verb RunAs pwsh -ArgumentList '-NoExit -ExecutionPolicy Bypass -File %location%'"