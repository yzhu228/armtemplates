$rgName = "az104-pwsh"
$vmSize = "Standard_B1s"
$storageType = "StandardSSD_LRS"

$avaiSet = Get-AzAvailabilitySet -ResourceGroupName $rgName -Name "pwsh-avs"
$nic = Get-AzNetworkInterface -Name pwsh-nic -ResourceGroupName $rgName
Set-AzNetworkInterfaceIpConfig -NetworkInterface $nic -Name "ipconfig1" -PublicIpAddressId $pip.Id
Set-AzNetworkInterface -NetworkInterface $nic

$vmConfig = New-AzVMConfig -VMName "linuxvm" -VMSize $vmSize -AvailabilitySetId $avaiSet.Id

Set-AzVMSourceImage -VM $vmConfig -PublisherName "Canonical" -Offer "0001-com-ubuntu-server-focal" -Skus "20_04-lts-gen2" -Version "Latest"
Set-AzVMOSDisk -VM $vmConfig -Linux -StorageAccountType $storageType -CreateOption "FromImage"
Set-AzVMOperatingSystem -VM $vmConfig -Linux -Credential (Get-Credential) -ComputerName "linuxvm1"
Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

New-AzVm -ResourceGroupName az104-pwsh -Location australiaeast -VM $vmConfig
