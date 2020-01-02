# usage:
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

$cmd = "-f docker-compose.yml"
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

    if ($DIG_ADD_ONS) {
        foreach ($curArg in $DIG_ADD_ONS.split(",")) {
            $cmd = "$($cmd) -f docker-compose.$($curArg).yml"
            $yml = "$($yml) -f docker-compose.$($curArg).yml"
        }
    }

}
else {
    # add parameter from .engine.status
    $lines = cat ".engine.status"
    $cmd = "$($cmd) $($lines)"
}

for ($i = 0; $i -lt $numOfArgs; $i++) {
    $curArg = $args[$i]
    if ($curArg.Substring(0, 1) -eq "+") {
        $curArg = $curArg.Substring(1) #remove plus sign
        $cmd = "$($cmd) -f docker-compose.$($curArg).yml"
        $yml = "$($yml) -f docker-compose.$($curArg).yml"
    }
    else {
        $cmd = "$($cmd) $($curArg)"
    }
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
    $FailureCount = 0
    $Success = $false

    Do {
        try {
            # web test code from stackoverflow: https://stackoverflow.com/a/20262872/5961793
            $HTTP_Request = [System.Net.WebRequest]::Create('http://localhost:12497/mydig/projects')
            $HTTP_Request.Credentials = new-object System.Net.NetworkCredential($DIG_AUTH_USER, $DIG_AUTH_PASSWORD);
            $HTTP_Response = $HTTP_Request.GetResponse()
            $HTTP_Status = [int]$HTTP_Response.StatusCode

            If ($HTTP_Status -eq 200) {
                $Success = $true
                Break
            }
        }
        catch {
        }
        finally {
            If ($null -eq $HTTP_Response) { } 
            Else { $HTTP_Response.Close() }
        }

        # Report failure
        if ($FailureCount -eq 0) {   # Report failure for first time
            Write-Host -ForegroundColor Yellow "DIG Server is not up yet, trying again" -NoNewline
        } else {
            Write-Host -ForegroundColor Yellow "." -NoNewline
        }
        $FailureCount = $FailureCount + 1
        Start-Sleep -Seconds 3
    } while ($FailueCount -le 10)

    Write-Host
    if ($Success) {
        Write-Host -ForegroundColor Green "DIG Server is up and running"
    } else {
        Write-Host -ForegroundColor Red "DIG Server is not up"
        Write-Host -ForegroundColor Red "Please make sure Docker has at least 8GB of memory available"
    }

}

Pop-Location