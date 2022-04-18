$script1 = [System.IO.Path]::Combine($PSScriptRoot, "InstallBuildTools.ps1")
$script2 = [System.IO.Path]::Combine($PSScriptRoot, "InstallIIs.ps1")

& $script1
& $script2
