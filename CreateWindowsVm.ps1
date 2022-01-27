$nic = Get-AzNetworkInterface -ResourceGroupName $az_base_info.ResourceGroup -Name $az_base_info.Nic

$vmconf = New-AzVMConfig -VMName "az104WindowsVm1" -VMSize "Standard_D2s_V3"
Set-AzVMOperatingSystem -VM $vmconf -Windows -Credential (Get-Credential) -ComputerName MyWebApp
Set-AzVMSourceImage -VM $vmconf -PublisherName "MicrosoftWindowsServer" -Offer "Windowsserver" -Skus "2019-Datacenter" -Version "2019.0.20190410"
Add-AzVMNetworkInterface -VM $vmconf -NetworkInterface $nic

New-AzVM -VM $vmconf -ResourceGroupName $az_base_info.ResourceGroup -Location $az_base_info.Location
