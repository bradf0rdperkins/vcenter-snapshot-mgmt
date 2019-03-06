Param(
[parameter(Mandatory=$true, HelpMessage="VMware vCenter IP/FQDN")]
[string]$vCenterIp
)

#Connect to vCenter
Connect-VIServer $vCenterIp

#Create snapshots of Linux VMs for patching

$VMs = Get-VM | Where-Object {$_.Guest.OSFullName -like "Red Hat*" -and $_.ExtensionData.Config.ManagedBy.extensionKey -notlike "com.vmware.vcDr*" -and $_.ExtensionData.Config.ManagedBy.Type -ne 'placeholderVm'}
foreach($VM in $VMs){
New-Snapshot -VM $vm.Name -Name $($VM.Name+"_autosnap.bak") -Description "Snapshot created via Automation tool prior to guest updates" -RunAsync
Write-Output $("Creating snapshot of " + $VM.Name)
}
