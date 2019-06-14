#region Add Computer Account to AD group
$TargetGroup = "sg-Intune-Computers"
$MaxRetries = 25
$RetryDelay = 5 # Seconds

try{
    # Group to be added to
    
    $i = 0
    while(($adComputerLength.Count -lt 1) -AND ($i -lt $MaxRetries)){
        $i++
        Write-Log "Start search try $i of $MaxRetries"
        Write-Log "Sleeping for $RetryDelay seconds before searching for computer"
        Start-Sleep -Seconds $RetryDelay
        try{
            Write-Log "Getting computer object with the name '$DeviceName' in the AD"
            $adComputer =  Get-ADComputer -Identity $DeviceName
            $adComputerLength = $adComputer | Measure-Object
        }catch{
            Write-Log "Computer with name '$DeviceName' not found, starting next try"
        }
        
    }
    Write-Log "Found computer '$DeviceName'"
    Write-Log "Adding '$DeviceName' to AD group '$TargetGroup'"
    ADD-ADGroupMember $TargetGroup –members $adComputer
} catch {
    Write-Log "Failed to add '$DeviceName' to AD group '$TargetGroup'" -Type Error -Exception $_.Exception
}
#endregion Add Computer Account to AD group