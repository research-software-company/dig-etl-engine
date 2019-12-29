# usage:
# ./engine.ps1 up
# ./start.ps1 +dev up
# ./engine.ps1 +dev +ache up -d
# ./engine.ps1 config
# ./engine.ps1 stop
# ./engine.ps1 down
# ./engine.ps1 restart mydig_ws

$cmd="-f docker-compose.yml"
$yml="" # additional yml files
$operation_up=$false


$numOfArgs = $args.Length
for ($i=0; $i -lt $numOfArgs; $i++)
{
    if($args[$i] -eq "up")
    {
   $operation_up = $true
   #echo "" > .engine.status
   }
}

if ($operation_up)
{
        $lines = cat ".env"

        foreach ($line in $lines) {
            $bits = $line.Split("=");
            $name = $bits[0];
            $val = $bits[1];
            Set-Variable $name $val
        }

        if ($DIG_ADD_ONS)
        {
        foreach ($curArg in $DIG_ADD_ONS.split(","))
        {
             $cmd= "$($cmd) -f docker-compose.$($curArg).yml"
             $yml="$($yml) -f docker-compose.$($curArg).yml"
        }
        }

}
else
{
 # add parameter from .engine.status
    #cmd="$cmd $(head -n 1 .engine.status)"
}

for ($i=0; $i -lt $numOfArgs; $i++)
{
     $curArg=$args[$i]
     if ($curArg.Substring(0,1) -eq "+")
     {
          $curArg=$curArg.Substring(1) #remove plus sign
          $cmd= "$($cmd) -f docker-compose.$($curArg).yml"
          $yml="$($yml) -f docker-compose.$($curArg).yml"
     }
     else
     {
          $cmd= "$($cmd) $($curArg)"
     }
}

#if [ "$operation_up" == true ]; then
#    echo "$yml" > .engine.status
#fi

$cmd = "docker-compose $($cmd)"
Write-Host $cmd
#Invoke-Expression -Command $cmd

#Invoke-WebRequest -UseBasicParsing -Uri http://localhost:12497/mydig/projects