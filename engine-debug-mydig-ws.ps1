﻿# usage:
# ./engine.ps1 up
# ./start.ps1 +dev up
# ./engine.ps1 +dev +ache up -d
# ./engine.ps1 config
# ./engine.ps1 stop
# ./engine.ps1 down
# ./engine.ps1 restart mydig_ws

# Change directory to the script's directory
$scriptpath = $MyInvocation.MyCommand.Path
$scriptdir = Split-Path $scriptpath
Push-Location $scriptdir

$cmd = "-f docker-compose.debug-mydig-ws.yml"
$yml = "" # additional yml files
$operation_up = $false


$numOfArgs = $args.Length
for ($i = 0; $i -lt $numOfArgs; $i++) {
    if ($args[$i] -eq "up") {
        $operation_up = $true
        
        #.engine.status records the contents of $yml. empty it for a new up command
        Set-Content -Path '.engine.status' -Value ''
        #echo "" > .engine.status
    }
}

if ($operation_up) {
    $lines = Get-Content ".env"

    foreach ($line in $lines) {
        $bits = $line.Split("=");
        $name = $bits[0];
        $val = $bits[1];
        Set-Variable $name $val
    }

    # if ($DIG_ADD_ONS) {
    #     foreach ($curArg in $DIG_ADD_ONS.split(",")) {
    #         $cmd = "$($cmd) -f docker-compose.$($curArg).yml"
    #         $yml = "$($yml) -f docker-compose.$($curArg).yml"
    #     }
    # }

}
else {
    # add parameter from .engine.status
	if (Test-Path ".engine.status")
	{
    $lines = cat ".engine.status"
    $cmd = "$($cmd) $($lines)"
	}
}

for ($i = 0; $i -lt $numOfArgs; $i++) {
    $curArg = $args[$i]
    # if ($curArg.Substring(0, 1) -eq "+") {
    #     $curArg = $curArg.Substring(1) #remove plus sign
    #     $cmd = "$($cmd) -f docker-compose.$($curArg).yml"
    #     $yml = "$($yml) -f docker-compose.$($curArg).yml"
    # }
    # else {
    #     $cmd = "$($cmd) $($curArg)"
    # }
    $cmd = "$($cmd) $($curArg)"
}

if ($operation_up) {
    #save contents of yml to .engine.status for future down commands
    Set-Content -Path '.engine.status' -Value $yml

    #run up in detach mode so we can check server status
    $cmd = "$($cmd) --detach"
}

$cmd = "docker-compose $($cmd)"
#Write-Host "run" $cmd
Invoke-Expression -Command $cmd



#check whether server is running correctly
if ($operation_up) {
    Write-Host "Checking that DIG server is running properly..."
    Start-Sleep -Seconds 5 #an initial sleep to give it time to start (in addition to the one below)
    $FailureCount = 0


    Write-Host
    Write-Host -ForegroundColor Green "DIG Server is up and running"

}

Pop-Location