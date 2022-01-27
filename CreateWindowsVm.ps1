$vnet = Get-AzVirtualNetwork -ResourceGroupName $az_base_info.ResourceGroup -Name $az_base_info.Vnet
$vnet_subnet_1 = $vnet.Subnets[0]
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $az_base_info.ResourceGroup -Name $az_base_info.Nsg
$credential = Get-Credential

foreach ($n in @{VmName = 'az104WindowsVm1'; Nic = 'az104Nic1'; DnsLable = "yzhuvm8991224" }, `
    @{VmName = 'az104WindowsVm2'; Nic = 'az104Nic2'; DnsLabel = "yzhuvm8991225" }) {

    $pubilcIp = New-AzPublicIpAddress -Location $az_base_info.Location -ResourceGroupName $az_base_info.ResourceGroup -Name "$($n.Nic)_publicIp" `
        -AllocationMethod Dynamic `
        -DomainNameLabel $n.DnsLabel

    $nic = New-AzNetworkInterface -Location $az_base_info.Location `
        -ResourceGroupName $az_base_info.ResourceGroup `
        -Name $n.Nic `
        -Subnet $vnet_subnet_1 `
        -NetworkSecurityGroup $nsg `
        -PublicIpAddress $pubilcIp

    $vmconf = New-AzVMConfig -VMName $n.VmName -VMSize "Standard_D2s_V3"
    Set-AzVMOperatingSystem -VM $vmconf -Windows -Credential $credential -ComputerName MyWebApp
    Set-AzVMSourceImage -VM $vmconf -PublisherName "MicrosoftWindowsServer" -Offer "Windowsserver" -Skus "2019-Datacenter" -Version "2019.0.20190410"
    Add-AzVMNetworkInterface -VM $vmconf -NetworkInterface $nic

    New-AzVM -VM $vmconf -ResourceGroupName $az_base_info.ResourceGroup -Location $az_base_info.Location
}