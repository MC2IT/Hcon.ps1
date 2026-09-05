# Installation

## Requirements
Before installing **HCON for PowerShell**, you need to make sure
you have [PowerShell](https://learn.microsoft.com/en-us/powershell) up and running.

You can verify if you're already good to go with the following command:

```shell
pwsh --version
# PowerShell 7.6.5
```

## Installing with PSResourceGet package manager

### 1. Install it
From a command prompt, run:

```powershell
Install-PSResource Mc2it.Hcon -Repository PSGallery
```

### 2. Import it
Now in your [PowerShell](https://learn.microsoft.com/en-us/powershell) code, you can use:

```powershell
using module Mc2it.Hcon
```
