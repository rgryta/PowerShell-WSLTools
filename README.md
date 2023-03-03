# WSL Tools - PowerShell Utility

## Description

This module can do several things other than simply installing WSL images. You can specify whether to restart your computer and continue your script. You can verify if HyperV is enabled, and enable it if not. Same with WSL installation.
	
Main feature is that you can install any available Ubuntu and/or Alpine Linux images as WSL images. No third parties, straight from official repositories. You can perform quiet installation, which will try to install the newest version, or you can launch scripts in -Interactive mode, which will ask you which version to grab and install.

## Installation


This repository has automatic deployment pipeline enabled. So the release is available directly from [PowerShell Gallery](https://www.powershellgallery.com/packages/WSLTools "PS Gallery: WSL Tools").

You can use it directly through PowerShell after executing:
```powershell
Install-Module -Name WSLTools
Import-Module WSLTools -WarningAction SilentlyContinue
```

## Available functions

See example under `install-wsl.ps1`. Open `install-wsl.bat` that will launch the PS script with elevated access rights. (By the way) You can use this script to install WSL - should also work on Windows Home Editions and if it doesn't, please submit a ticket.

### Ensure-HyperV 

Ensures that HyperV is enabled. If -Install is set, then it will try to enable it (if necessary). Restart will be required afterwards.
```powershell
Ensure-HyperV [-Install]
```

### Ensure-NewPS 

Installs new PowerShell. Two sources can be provided: Git (recommended) or MS Store. To enable Git source, use -Git flag. To invoke installation process through PowerShell, provide -Install flag. To be able to choose which version to install, use -Interactive flag.
```powershell
Ensure-NewPS [-Git] [-Install] [-Interactive]
```

### Ensure-WSL

Ensures that WSL is installed (from MS Store). If -Install is set, then it will be installed quietly. No restart required.
```powershell
Ensure-WSL [-Install]
```

### Run-AfterReboot

Reboot the system and automatically run a command once it's back up. Uses registry edits to add entry to runOnce section.

```powershell
$command = "pwsh ""Start-Process pwsh -ArgumentList '-NoExit -ExecutionPolicy Bypass -file """"E:\example.ps1""""'"""
Run-AfterReboot -Command $command
```

### WSL-Alpine-Install

Deploys Alpine Linux distro into WSL. Takes only official repository source into account, so it's alway up-to-date. Provide alias (DistroAlias parameter) for you distribution to use with `wsl -d $distro` after installation. Provide custom installation path (InstallPath) if you want to install your distro under specific directory (by default it's `<current_dir>/install`). Use flag -Interactive to manually go through installation process, check which version to install and whether 32 or 64 bit versions. Defaults to newest deployment.
```powershell
WSL-Alpine-Install [-Interactive] [-DistroAlias <alias>] [-InstallPath <path>]
```

### WSL-Ubuntu-Install

Deploys clean Ubuntu Linux distro into WSL. Usage is the same to WSL-Alpine-Install. Currently takes lunar as default.
```powershell
WSL-Ubuntu-Install [-Interactive] [-DistroAlias <alias>] [-InstallPath <path>]
```

### WSL-Debian-Install

Deploys clean Debian Linux distro into WSL. Usage is the same to WSL-Alpine-Install. Currently takes bullseye-full as default.
```powershell
WSL-Debian-Install [-Interactive] [-DistroAlias <alias>] [-InstallPath <path>]
```
