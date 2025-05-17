# Requires administrator privileges
# Check if running as administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "This script requires administrator privileges. Please run as administrator."
    Exit 1
}

Write-Host "Configuring Windows Firewall rules for Firebase..."

# Create more specific outbound rules for Firebase services
$rules = @(
    @{
        DisplayName = "Allow Firebase HTTPS"
        Description = "Allow outbound HTTPS access to Firebase services"
        Program = "Any"
        Protocol = "TCP"
        RemotePort = "443"
        RemoteAddress = "Internet"
    },
    @{
        DisplayName = "Allow Firebase Firestore"
        Description = "Allow outbound access to Firebase Firestore"
        Program = "Any"
        Protocol = "TCP"
        RemotePort = "443,8443"
        RemoteAddress = "Internet"
    },
    @{
        DisplayName = "Allow Firebase Auth"
        Description = "Allow outbound access to Firebase Authentication services"
        Program = "Any"
        Protocol = "TCP"
        RemotePort = "443"
        RemoteAddress = "Internet"
    },
    @{
        DisplayName = "Allow Google APIs HTTPS"
        Description = "Allow outbound HTTPS access to Google APIs"
        Program = "Any"
        Protocol = "TCP"
        RemotePort = "443"
        RemoteAddress = "Internet"
    },
    @{
        DisplayName = "Allow Flutter Debug"
        Description = "Allow Flutter debug connections"
        Program = "Any"
        Protocol = "TCP"
        LocalPort = "8080-9000"
        RemotePort = "Any"
        RemoteAddress = "LocalSubnet"
    }
)

foreach ($rule in $rules) {
    $existingRule = Get-NetFirewallRule -DisplayName $rule.DisplayName -ErrorAction SilentlyContinue

    if (-not $existingRule) {
        Write-Host "Creating firewall rule: $($rule.DisplayName)"
        
        $params = @{
            DisplayName = $rule.DisplayName
            Description = $rule.Description
            Direction = "Outbound"
            Protocol = $rule.Protocol
            Action = "Allow"
            Program = $rule.Program
            Service = "Any"
            Profile = "Any"
            Enabled = $true
        }
        
        if ($rule.LocalPort) {
            $params.Add("LocalPort", $rule.LocalPort)
        } else {
            $params.Add("LocalPort", "Any")
        }
        
        if ($rule.RemotePort) {
            $params.Add("RemotePort", $rule.RemotePort)
        } else {
            $params.Add("RemotePort", "Any")
        }
        
        if ($rule.RemoteAddress) {
            $params.Add("RemoteAddress", $rule.RemoteAddress)
        }
        
        New-NetFirewallRule @params
    } else {
        Write-Host "Firewall rule already exists: $($rule.DisplayName)"
        # Update the existing rule to ensure it's enabled
        Set-NetFirewallRule -DisplayName $rule.DisplayName -Enabled True
    }
}

Write-Host "`nDisabling any potentially blocking inbound rules..."
# Ensure Flutter and Dart executables can receive inbound connections if needed
$dartExePaths = @(
    "${env:LOCALAPPDATA}\Pub\Cache\bin\dart.exe",
    "${env:ProgramFiles}\Flutter\bin\dart.exe",
    "${env:ProgramFiles}\Flutter\bin\cache\dart-sdk\bin\dart.exe"
)

foreach ($dartPath in $dartExePaths) {
    if (Test-Path $dartPath) {
        $ruleName = "Allow Dart Inbound ($dartPath)"
        $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
        
        if (-not $existingRule) {
            Write-Host "Creating inbound rule for: $dartPath"
            New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Program $dartPath -Action Allow
        } else {
            Write-Host "Inbound rule already exists for: $dartPath"
        }
    }
}

Write-Host "`nAdding domain rules to Windows hosts to ensure proper resolution..."

# Add domain entries to hosts file if they don't exist
$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$domains = @(
    "firebaseio.com",
    "googleapis.com",
    "firestore.googleapis.com",
    "identitytoolkit.googleapis.com",  # Firebase Auth
    "wellnex-84c5e.firebaseapp.com",   # Add your actual Firebase app domain
    "wellnex-84c5e.firebasestorage.app"
)

$currentHosts = Get-Content $hostsPath
foreach ($domain in $domains) {
    if (-not ($currentHosts -match $domain)) {
        Write-Host "Adding domain to hosts file: $domain"
        Add-Content -Path $hostsPath -Value "`n# Firebase domains`n# $domain"
    }
}

Write-Host "`nChecking if Windows Defender Firewall is running..."
$firewallService = Get-Service -Name MpsSvc
if ($firewallService.Status -eq "Running") {
    Write-Host "Windows Defender Firewall is running."
} else {
    Write-Host "Warning: Windows Defender Firewall is not running. Starting it now..."
    Start-Service -Name MpsSvc
}

Write-Host "`nFirewall configuration completed!"
Write-Host "Please restart your Flutter application to test the Firebase connection."

# Display current rules
Write-Host "`nCurrent Firebase related firewall rules:"
Get-NetFirewallRule | Where-Object { 
    $_.DisplayName -like "*Firebase*" -or $_.DisplayName -like "*Flutter*" -or $_.DisplayName -like "*Google*" 
} | Format-Table DisplayName, Description, Enabled, Action 