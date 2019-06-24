#region Remove old Computer Account from AD based on Computername Pattern
$upn = "intune.svc@kurcontoso.ch"
$passWD = "01000000d08c9ddfasdasd77f7f228164e30000000002000000000010660234238993c5d39482a16f41cc129f79245def666935f449b9bbb25d924e652d0a720008967986679000200000001b68dd8723765f65111403969403b4c105573f1821de5757bdd80e1a8e92a88630000000a215aea947d3b7ce63eef9f4a1397a1d76f627733f8cc0f14a36acbf1a63e1dcf8ed3090566d68be11f170cf6226aaef4000000044dc72c8d3ea5cf82cdce6ca8096360e76f2ef8f1ba848c13c31bc78621cf3eed81ee1add96caad871d4baa91387bdb139baba0cad721c4503eec1c961c47d1c"

$maxDevicesToDelete = 3 # If more devices are returned, the script will not delete them.
$MaxRetries = 25
$RetryDelay = 5 # Seconds

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


if(($intuneDevice) )
{
   try{
        Write-Log "Getting all devices with same serialnumber '$DeviceSerial' like device id '$DeviceId'"
        
        $intuneOldDevices = Get-IntuneManagedDevice -Filter "serialNumber eq '$DeviceSerial'"
        if($intuneOldDevices.Count -lt ($maxDevicesToDelete + 1)){ # Add one to the Max because one device will be excluded 
            foreach($intuneOldDevice in $intuneOldDevices){
                if($intuneOldDevice.id -eq $DeviceId){
                    Write-Log "Identical device id '$DeviceId', do nothing with this object."
                } else {
                    Write-Log "Found device id '$($intuneOldDevice.id)', remove object."
                    Remove-IntuneManagedDevice -managedDeviceId $intuneOldDevice.id
                }
            }
        }
    } catch{
        if($_.TargetObject.Response.HttpStatusCode -eq 404){
            Write-Log "Device not found in Intune continuing with the script"
        }else{
            Write-Log "Could not get new device name" -Type Error -Exception $_.Exception
        }
    }
}else{
    Write-Log "Target devicename not set. Skipping device removal."
}
#endregion Add Computer Account to AD group