#Requires -RunAsAdministrator

# Check user has webhook URL ready
$userPrompt = Read-Host -Prompt "Do you have your webhook URL ready? Y/N"

# Prompt user to create webhook first if not ready
If ($userPrompt -ne 'Y') {
    Write-Output "Please create a Discord webhook before continuing. `nFull instructions avalible at https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks"
    exit
}

# Get latest release from GitHub
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$latestRelease = Invoke-WebRequest -Uri https://github.com/tigattack/VeeamDiscordNotifications/releases/latest -ContentType 'application/json' -UseBasicParsing

# Release IDs are returned in a format of {"id":3622206,"tag_name":"v1.0"} so we need to extract tag_name.
$latestVersion = ($latestRelease.Content | ConvertFrom-Json).tag_name

# Pull latest version of script from GitHub
Invoke-WebRequest -Uri https://github.com/tigattack/VeeamDiscordNotifications/releases/download/$latestVersion/VeeamDiscordNotifications-$latestVersion.zip -OutFile $PSScriptRoot\VeeamDiscordNotifications-$latestVersion.zip

# Expand downloaded ZIP and cleanup
Expand-Archive $PSScriptRoot\VeeamDiscordNotifications-$latestVersion.zip -DestinationPath C:\VeeamScripts
Rename-Item C:\VeeamScripts\VeeamDiscordNotifications-$latestVersion C:\VeeamScripts\VeeamDiscordNotifications
Remove-Item $PSScriptRoot\VeeamDiscordNotifications-$latestVersion.zip

# Assign webhook url to variable
$webhookUrl = Read-Host -Prompt "Please paste your webhook URL now"

# Get the config file and write the user webhook
$config = Get-Content "C:\VeeamScripts\VeeamDiscordNotifications\config\conf.json" -Raw | ConvertFrom-Json
$config.webhook = $webhookUrl

# Write Config
ConvertTo-Json $config | Set-Content C:\VeeamScripts\VeeamDiscordNotifications\config\conf.json

# Unblock script files
Unblock-File C:\VeeamScripts\VeeamDiscordNotifications\DiscordNotificationBootstrap.ps1
Unblock-File C:\VeeamScripts\VeeamDiscordNotifications\DiscordVeeamAlertSender.ps1
Unblock-File C:\VeeamScripts\VeeamDiscordNotifications\resources\logger.psm1
Unblock-File C:\VeeamScripts\VeeamDiscordNotifications\UpdateVeeamDiscordNotification.ps1

# Display the command for Veeam
Write-Output "Success. Copy the following command into the following area of each job you would like to have reported."
Write-Output "`nJob settings -> Storage -> Advanced -> Scripts -> Post-Job Script"
Write-Output "Powershell.exe -ExecutionPolicy Bypass -File C:\VeeamScripts\VeeamDiscordNotifications\DiscordNotificationBootstrap.ps1"
