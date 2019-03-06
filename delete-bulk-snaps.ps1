Param(
[parameter(Mandatory=$true, HelpMessage="VMware vCenter IP/FQDN")]
[string]$vCenterIp
)

#Connect to vCenter
Connect-VIServer $vCenterIp

#Delete snapshots of Linux VMs for patching
$VMs = Get-VM | Where-Object {$_.Guest.OSFullName -like "Red Hat*" -and $_.ExtensionData.Config.ManagedBy.extensionKey -notlike "com.vmware.vcDr*" -and $_.ExtensionData.Config.ManagedBy.Type -ne 'placeholderVm'}
foreach($VM in $VMs){
  Get-Snapshot -Name * -VM $vm.Name | ? {$_.Name -like "*_autosnap.bak"} | Remove-Snapshot -Confirm:$false -RunAsync
  Write-Output $("Deleting snapshot of " + $VM.Name + " created by automation platform")
}
