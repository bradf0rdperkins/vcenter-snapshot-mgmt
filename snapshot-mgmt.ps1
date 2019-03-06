Param(
[parameter(Mandatory=$true, HelpMessage="VMware vCenter IP/FQDN")]
[string]$vCenterIp
)

#Connect to vCenter 
Connect-VIServer $vCenterIp

$snapshots = Get-Cluster | ?{$_.Name -notlike "*filter*" } | Get-VM | Get-Snapshot | ? {$_.created -lt (Get-Date).AddDays(-5)}

foreach ($snap in $snapshots){
    $snap | Remove-Snapshot -Confirm:$false -RunAsync
    Write-Output $("Deleting snapshot " + $snap.Name + " from server " + $snap.vm.name + ". Size: " + $snap.SizeGB)
    Start-Sleep -Seconds 2
}

$consolidateDisks=@()
foreach ($vm in $snapshots){
    $cvm = Get-VM -Name $vm.VM | ?{$_.ExtensionData.Runtime.ConsolidationNeeded}
    $consolidateDisks += $cvm
}

foreach ($server in $consolidateDisks){
    (Get-VM $server).ExtensionData.ConsolidateVMDisks_Task()
    Write-Output $("Consolidating " + $server)
}
