Install-WindowsFeature -Name Web-Server -IncludeManagementTools
Set-Content -Path C:\inetpub\wwwroot\default.html -Value "<h2>This is server $($env:computername)</h2>"
