# Remove old Computer Account from AD based on Computername Pattern
# This example will work only when you use a Prefix and the serial Name as Computername.

#region Add this region to the configuration section of the existing ODJ-Extender Script
$upn = "intune.svc@kurcontoso.ch"
$passWD = "01000000d08c9ddfasdasd77f7f228164e30000000002000000000010660234238993c5d39482a16f41cc129f79245def666935f449b9bbb25d924e652d0a720008967986679000200000001b68dd8723765f65111403969403b4c105573f1821de5757bdd80e1a8e92a88630000000a215aea947d3b7ce63eef9f4a1397a1d76f627733f8cc0f14a36acbf1a63e1dcf8ed3090566d68be11f170cf6226aaef4000000044dc72c8d3ea5cf82cdce6ca8096360e76f2ef8f1ba848c13c31bc78621cf3eed81ee1add96caad871d4baa91387bdb139baba0cad721c4503eec1c961c47d1c"
$ComputerNamePrefix = "KUR-" # This will be added in front of the Serial Number
$maxDevicesToDelete = 3
$MaxRetries = 25
$RetryDelay = 5 # Seconds

#endregion

#region Add this region to the initialization section of the existing ODJ-Extender Script

try {
    #import the Intune Powershell module
    Write-Log "import Microsoft.Graph.Intune PSModule"
    Import-Module Microsoft.Graph.Intune -Force -ErrorAction Stop | Out-Null
} catch {
    Write-Log "Coul not load Microsoft.Graph.Intune module. Trying to install and then import it."
    #Install Intune PowerShell module and then import it
    Install-Module Microsoft.Graph.Intune -Force
    Import-Module Microsoft.Graph.Intune -Force -ErrorAction Stop | Out-Null
    if((Get-Module -Name Microsoft.Graph.Intune) -eq $null){
        Write-Log "Could not import Microsoft.Graph.Intnue module. Data collection will be aborted." -Type Error
        throw "Could not import Microsoft.Graph.Intnue module."
    }
}

try {
    #create the connection credentials
    Write-Log "Converting Password to securestring"
    $secPwd = ConvertTo-SecureString $passWD
    $credentials = New-Object System.Management.Automation.PSCredential($upn,$secPwd)
    Write-Log "Connecting to intune"
    #connect to Intune without Outputing to the console.
    Connect-MSGraph -PSCredential $credentials
} catch {
    Write-Log "Could not connet to Intune." -Type Error -Exception $_.Exception
    throw "Could not connect to Intune"
}
#endregion

#region Add this region to the beginning of the main section. To optimze you can check if the first try catch is already available because of another example script, then you don't have to add it again.

try{
    Write-Log "Getting serialnumber for device id '$DeviceId'"
    $i = 0
    while(($intuneDevice.serialNumber.Length -lt 1) -and ($i -lt $MaxRetries)){
        $i++
        Write-Log "Start searching Intune by DeviceId (Try: '$i')"
        Start-Sleep -Seconds $RetryDelay
        $intuneDevice = Get-IntuneManagedDevice -managedDeviceId $DeviceId
        $DeviceSerial = $intuneDevice.serialNumber
    }
    
} catch{
    if($_.TargetObject.Response.HttpStatusCode -eq 404){
        Write-Log "Device not found in Intune continuing with the script"
    }else{
        Write-Log "Could not get new device name" -Type Error -Exception $_.Exception
    }
}


#Building Devicename to search for it in AD
Write-Log "Building Target Devicename"
$TargetComputername = "KUR-$DeviceSerial"
Write-Log "Target ComputerName: '$TargetComputername'"
  
if ($TargetComputername.Length -ge 15) {
    Write-Log "Target ComputerName is longer ($($TargetComputername.Length)) than the allowed length of 15. It will be shorted."
    $TargetComputername = $TargetComputername.substring(0, 15)
    Write-Log "New Target ComputerName: '$TargetComputername' "
}


if(($intuneDevice) -and ($TargetComputername.Length -gt 4))
{
    Write-Log "Delete device from AD with devicename '$TargetComputername'"
    try{
        $devicesToDelete = @(Get-ADComputer -Identity $TargetComputername)
        if($devicesToDelete.Count -le $maxDevicesToDelete){
            Write-Log "Found '$($devicesToDelete.Count)' devices. This is below the configured value of '$maxDevicesToDelete'. Therefore deleting those devices."
            foreach($deviceToDelete in $devicesToDelete){
                Write-Log "Removing '$($deviceToDelete.DistinguishedName)'"
                try{
                    Remove-ADObject -Identity $deviceToDelete -Recursive -Confirm:$FALSE
                }catch{
                    Write-Log "Could not remove device" -Type Error -Exception $_.Exception
                }
            }
        }else{
            Write-Log "Found '$($devicesToDelete.Count)' devices. This is above the configured value of '$maxDevicesToDelete'. Therefore skipping those devices."
        }
    }catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        Write-Log "AD object for '$TargetComputername' not found, skipping device removal"
    }catch{
        Write-Log "Error on deleting device." -Type Error -Exception $_.Exception
    }
}else{
    Write-Log "Target devicename not set. Skipping device removal."
}
#endregion Add Computer Account to AD group