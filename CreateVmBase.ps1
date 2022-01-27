$az_location = "australiasoutheast"
$az_resourcegroup = "az104"
$az_vnet = "az104Vnet"
$az_vnic = "az104Vnic"
$az_publicIp = "az104PublicIp"
$az_nsg = "az104Nsg"
$az_pub_subnet1 = "az104PubSubnet1"
$az_pub_subnet2 = "az104PubSubnet2"
$az_dnsLabel = "yzhuvm8991221"

New-AzResourceGroup -Location $az_location -Name $az_resourcegroup

$vnet_subnet_1 = New-AzVirtualNetworkSubnetConfig -Name $az_pub_subnet1 -AddressPrefix "192.168.1.0/24"
$vnet_subnet_2 = New-AzVirtualNetworkSubnetConfig -Name $az_pub_subnet2 -AddressPrefix "192.168.2.0/24"

$vnet = New-AzVirtualNetwork -Location $az_location -ResourceGroupName $az_resourcegroup `
    -Name $az_vnet `
    -AddressPrefix "192.168.0.0/16" `
    -Subnet $vnet_subnet_1, $vnet_subnet_2

$pubilcIp = New-AzPublicIpAddress -Location $az_location -ResourceGroupName $az_resourcegroup -Name $az_publicIp `
    -AllocationMethod Dynamic `
    -DomainNameLabel $az_dnsLabel

$securityGroupRuleRDP = New-AzNetworkSecurityRuleConfig -Name "rdp-rule" -Access Allow -Protocol Tcp `
    -Direction Inbound -Priority 1010 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 3389

$securityGroupRuleWeb = New-AzNetworkSecurityRuleConfig -Name "web-rule" -Access Allow -Protocol Tcp `
    -Direction Inbound -Priority 1020 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 80

$securitGroup = New-AzNetworkSecurityGroup -Name $az_nsg -ResourceGroupName $az_resourcegroup -Location $az_location `
    -SecurityRules $securityGroupRuleRDP, $securityGroupRuleWeb

$vnet_subnet_1 = Get-AzVirtualNetworkSubnetConfig -Name $az_pub_subnet1 -VirtualNetwork $vnet
$vnic = New-AzNetworkInterface -Location $az_location `
    -ResourceGroupName $az_resourcegroup `
    -Name $az_vnic `
    -Subnet $vnet_subnet_1 `
    -NetworkSecurityGroup $securitGroup `
    -PublicIpAddress $pubilcIp
    
$global:az_base_info = @{ 
    Location      = $az_location;
    ResourceGroup = $az_resourcegroup;
    Nic           = $az_vnic;
}


