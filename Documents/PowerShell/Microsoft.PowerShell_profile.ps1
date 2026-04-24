# Microsoft.PowerShell_profile.ps1

Write-Host "Profile loaded! /help" -ForegroundColor Cyan

$asciiArt = @'
               ___   ___                   __                   
              /\_ \ /\_ \                 /\ \                  
  ___   __  __\//\ \\//\ \      __        \_\ \     __  __  __ 
/' _ `\/\ \/\ \ \ \ \ \ \ \   /'__`\      /'_` \  /'__`/\ \/\ \
/\ \/\ \ \ \_\ \ \_\ \_\_\ \_/\ \L\.\_ __/\ \L\ \/\  __\ \ \_/ |
\ \_\ \_\/`____ \/\____/\____\ \__/.\_/\_\ \___,_\ \____\ \___/ 
 \/_/\/_/`/___/> \/____\/____/\/__/\/_\/_/\/__,_ /\/____/\/__/  
            /\___/                                              
            \/__/                                               
'@

Write-Host $asciiArt -ForegroundColor DarkMagenta
Write-Host ""


# ============================================================
# Appearance
# ============================================================

$script:colorPrefFile = "$env:USERPROFILE\ps_color_pref.txt"
$script:validColors   = @("black","blue","cyan","darkblue","darkcyan","darkgray","darkgreen","darkmagenta","darkred","darkyellow","gray","green","magenta","red","white","yellow")
$script:defaultColor  = "green"

# Curated palettes using color theory (analogous / split):
#   text   = terminal foreground + FormatAccent (list-view property labels)
#   accent = table headers (Mode, LastWriteTime, Length, Name) + directory names
#
#   CustomTableHeaderLabel is set to accent so "Length" (which PS7 treats as a
#   non-property header for directories) matches the other table headers.

$script:paletteMap = @{
    #              text color      text ANSI        accent ANSI
    "green"       = @{ text = "green";       textAnsi = "`e[92m"; accent = "`e[93m" }   # accent: bright yellow
    "darkgreen"   = @{ text = "darkgreen";   textAnsi = "`e[32m"; accent = "`e[33m" }   # accent: dark yellow
    "cyan"        = @{ text = "cyan";        textAnsi = "`e[96m"; accent = "`e[94m" }   # accent: bright blue
    "darkcyan"    = @{ text = "darkcyan";    textAnsi = "`e[36m"; accent = "`e[34m" }   # accent: dark blue
    "blue"        = @{ text = "blue";        textAnsi = "`e[94m"; accent = "`e[96m" }   # accent: bright cyan
    "darkblue"    = @{ text = "darkblue";    textAnsi = "`e[34m"; accent = "`e[36m" }   # accent: dark cyan
    "yellow"      = @{ text = "yellow";      textAnsi = "`e[93m"; accent = "`e[33m" }   # accent: dark yellow
    "darkyellow"  = @{ text = "darkyellow";  textAnsi = "`e[33m"; accent = "`e[32m" }   # accent: dark green
    "magenta"     = @{ text = "magenta";     textAnsi = "`e[95m"; accent = "`e[91m" }   # accent: bright red
    "darkmagenta" = @{ text = "darkmagenta"; textAnsi = "`e[35m"; accent = "`e[31m" }   # accent: dark red
    "red"         = @{ text = "red";         textAnsi = "`e[91m"; accent = "`e[35m" }   # accent: dark magenta
    "darkred"     = @{ text = "darkred";     textAnsi = "`e[31m"; accent = "`e[35m" }   # accent: dark magenta
    "white"       = @{ text = "white";       textAnsi = "`e[97m"; accent = "`e[33m" }   # accent: dark yellow
    "gray"        = @{ text = "gray";        textAnsi = "`e[37m"; accent = "`e[36m" }   # accent: dark cyan
    "darkgray"    = @{ text = "darkgray";    textAnsi = "`e[90m"; accent = "`e[34m" }   # accent: dark blue
    "black"       = @{ text = "black";       textAnsi = "`e[30m"; accent = "`e[90m" }   # accent: dark gray
}

# Applies full palette:
#   ForegroundColor          = text color (file names, typed text)
#   TableHeader              = accent (Mode, LastWriteTime, Length, Name headers)
#   CustomTableHeaderLabel   = accent (italic headers like Length for directories)
#   FileInfo.Dir             = accent (folder names in ls)
#   FormatAccent             = text ANSI (list-view property labels)
function Set-TerminalColorScheme {
    param ([string]$colorName)
    $palette = $script:paletteMap[$colorName]
    if ($palette) {
        $Host.UI.RawUI.ForegroundColor              = $palette.text
        $PSStyle.FileInfo.Directory                 = $palette.accent
        $PSStyle.Formatting.TableHeader             = $palette.accent
        $PSStyle.Formatting.CustomTableHeaderLabel  = $palette.accent
        $PSStyle.Formatting.FormatAccent            = $palette.textAnsi
    }
}

# Load saved color on startup (default: green)
$script:startupColor = $script:defaultColor
if (Test-Path $script:colorPrefFile) {
    $saved = Get-Content $script:colorPrefFile
    if ($saved -in $script:validColors) { $script:startupColor = $saved }
}
Set-TerminalColorScheme $script:startupColor

# Re-apply palette after every command (prevents ls etc. from resetting colors)
function prompt {
    $activeColor = $script:defaultColor
    if (Test-Path $script:colorPrefFile) {
        $saved = Get-Content $script:colorPrefFile
        if ($saved -in $script:validColors) { $activeColor = $saved }
    }
    $palette = $script:paletteMap[$activeColor]
    if ($palette) {
        $Host.UI.RawUI.ForegroundColor              = $palette.text
        $PSStyle.FileInfo.Directory                 = $palette.accent
        $PSStyle.Formatting.TableHeader             = $palette.accent
        $PSStyle.Formatting.CustomTableHeaderLabel  = $palette.accent
        $PSStyle.Formatting.FormatAccent            = $palette.textAnsi
    }
    "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "
}


# ============================================================
# Functions
# ============================================================

# 1. === TOUCH (CREATE FILE) === #
function New-File {
    param (
        [Parameter(Mandatory=$true, Position=0, ValueFromRemainingArguments=$true)]
        [string[]]$FileName
    )
    foreach ($name in $FileName) {
        $filePath = Join-Path -Path (Get-Location) -ChildPath $name
        if (Test-Path $filePath) {
            (Get-Item $filePath).LastWriteTime = Get-Date
            Write-Host "Updated timestamp: $filePath" -ForegroundColor Cyan
        } else {
            New-Item -Path $filePath -ItemType File -Force | Out-Null
            Write-Host "Created: $filePath" -ForegroundColor Cyan
            Write-Host " "
        }
    }
}


# 2. === INTERACTIVE COLOR PICKER === #
function Set-ConsoleColor {
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [string]$colorName
    )

    # Show interactive menu if no argument given
    if (-not $colorName) {
        $currentColor = $script:defaultColor
        if (Test-Path $script:colorPrefFile) {
            $saved = Get-Content $script:colorPrefFile
            if ($saved -in $script:validColors) { $currentColor = $saved }
        }

        Write-Host ""
        Write-Host "  Current color : " -NoNewline -ForegroundColor DarkGray
        Write-Host $currentColor -ForegroundColor $currentColor
        Write-Host ""
        Write-Host "  Available colors:" -ForegroundColor DarkGray
        Write-Host ""

        $i = 1
        foreach ($c in $script:validColors) {
            $accentCode = $script:paletteMap[$c].accent
            Write-Host "  [$i]" -NoNewline -ForegroundColor DarkGray
            Write-Host " $c" -NoNewline -ForegroundColor $c
            Write-Host " $([char]27)$($accentCode.Substring(1))████$([char]27)[0m"
            $i++
        }

        Write-Host ""
        Write-Host "  [0]" -NoNewline -ForegroundColor DarkGray
        Write-Host " default " -NoNewline -ForegroundColor Green
        Write-Host "(green + yellow accent)" -ForegroundColor DarkGray

        Write-Host ""
        Write-Host "  Enter a number or color name (Enter to cancel): " -NoNewline -ForegroundColor DarkGray
        $userInput = Read-Host

        if ([string]::IsNullOrWhiteSpace($userInput)) {
            Write-Host "  No changes made." -ForegroundColor DarkGray
            Write-Host ""
            return
        }

        # [0] or "default" = reset
        if ($userInput -eq "0" -or $userInput.ToLower().Trim() -eq "default") {
            if (Test-Path $script:colorPrefFile) { Remove-Item $script:colorPrefFile -Force }
            Set-TerminalColorScheme $script:defaultColor
            Write-Host ""
            Write-Host "  Reset to default: " -NoNewline -ForegroundColor DarkGray
            Write-Host $script:defaultColor -ForegroundColor $script:defaultColor
            Write-Host ""
            return
        }

        # Select by number
        if ($userInput -match '^\d+$') {
            $index = [int]$userInput - 1
            if ($index -ge 0 -and $index -lt $script:validColors.Count) {
                $colorName = $script:validColors[$index]
            } else {
                Write-Host "  Invalid number. Run 'color' to see options." -ForegroundColor Red
                Write-Host ""
                return
            }
        } else {
            $colorName = $userInput.ToLower().Trim()
        }
    }

    # Handle "default" as direct argument (e.g. color default)
    if ($colorName.ToLower() -eq "default") {
        if (Test-Path $script:colorPrefFile) { Remove-Item $script:colorPrefFile -Force }
        Set-TerminalColorScheme $script:defaultColor
        Write-Host ""
        Write-Host "  Reset to default: " -NoNewline -ForegroundColor DarkGray
        Write-Host $script:defaultColor -ForegroundColor $script:defaultColor
        Write-Host ""
        return
    }

    # Validate and apply
    if ($colorName -in $script:validColors) {
        $colorName | Out-File $script:colorPrefFile
        Set-TerminalColorScheme $colorName
        Write-Host ""
        Write-Host "  Color set to: " -NoNewline -ForegroundColor DarkGray
        Write-Host $colorName -ForegroundColor $colorName
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "  '$colorName' is not a valid color. Run 'color' to see options." -ForegroundColor Red
        Write-Host ""
    }
}


# 3. === GO TO ONEDRIVE === #
function Set-LocationToOneDrive {
    $oneDrivePath = "C:\Users\$env:USERNAME\OneDrive"
    if (Test-Path $oneDrivePath) {
        Set-Location -Path $oneDrivePath
    } else {
        Write-Host "OneDrive folder not found at $oneDrivePath" -ForegroundColor Red
    }
}


# 4. === RESTART PROFILE === #
function Restart-Profile {
    . $PROFILE
    Write-Host "Profile reloaded." -ForegroundColor Yellow
    Write-Host " "
}


# 5. === SHOW PROFILE PATH === #
function Get-ProfilePath {
    Write-Host $PROFILE -ForegroundColor Cyan
    Write-Host " "
}


# 6. === OPEN CURRENT FOLDER === #
function Show-CurrentLocation {
    Invoke-Item $PWD
}


# 7. === GO TO DOCUMENTS === #
function Set-LocationToDocument {
    $documentsPath = "C:\Users\$env:USERNAME\Documents"
    if (Test-Path $documentsPath) {
        Set-Location -Path $documentsPath
    } else {
        Write-Host "Documents folder not found at $documentsPath" -ForegroundColor Red
    }
}


# 8. === GO TO D DRIVE === #
function Set-LocationToDDrive {
    Set-Location D:\
}


# 9. === GO TO C DRIVE === #
function Set-LocationToCDrive {
    Set-Location C:\
}


# 10. === OPEN NEW WINDOWS TERMINAL TAB === #
function Start-NewTab {
    wt -w 0 nt -d .
}


# ============================================================
# Help
# ============================================================

$CommandHelp = @{
    "/help"     = "Displays this list of available commands."
    "touch"     = "touch <filename.ext> -- Creates or timestamps a file."
    "color"     = "color -- Interactive color picker. 'color <n>' or 'color default' to reset."
    "onedrive"  = "Navigate directly to OneDrive."
    "documents" = "Navigate directly to Documents."
    "restart"   = "Reload the profile."
    "path"      = "Show the profile file path."
    "open"      = "Open the current folder in Explorer."
    "ddrive"    = "Navigate to D: drive."
    "cdrive"    = "Navigate to C: drive."
    "new-tab"   = "new-tab / nt -- Open a new Windows Terminal tab in the current directory."
}

function Show-Help {
    Write-Host ""
    Write-Host "  Available Commands:" -ForegroundColor Green
    Write-Host "  ------------------" -ForegroundColor DarkGray
    foreach ($cmd in ($CommandHelp.Keys | Sort-Object)) {
        Write-Host "  $cmd" -NoNewline -ForegroundColor Cyan
        Write-Host " : $($CommandHelp[$cmd])" -ForegroundColor DarkGray
    }
    Write-Host ""
}


# ============================================================
# Aliases
# ============================================================

Set-Alias -Name "touch"     -Value "New-File"
Set-Alias -Name "color"     -Value "Set-ConsoleColor"
Set-Alias -Name "onedrive"  -Value "Set-LocationToOneDrive"
Set-Alias -Name "documents" -Value "Set-LocationToDocument"
Set-Alias -Name "restart"   -Value "Restart-Profile"
Set-Alias -Name "path"      -Value "Get-ProfilePath"
Set-Alias -Name "open"      -Value "Show-CurrentLocation"
Set-Alias -Name "/help"     -Value "Show-Help"
Set-Alias -Name "ddrive"    -Value "Set-LocationToDDrive"
Set-Alias -Name "cdrive"    -Value "Set-LocationToCDrive"
Set-Alias -Name "new-tab"   -Value "Start-NewTab"
Set-Alias -Name "nt"        -Value "Start-NewTab"