#!/usr/bin/env bash

# usage:
# ./engine.sh up
# ./start.sh +dev up
# ./engine.sh +dev +ache up -d
# ./engine.sh config
# ./engine.sh stop
# ./engine.sh down
# ./engine.sh restart mydig_ws

cmd="-f docker-compose.yml"
yml="" # additional yml files
operation_up=false
operation_down=false

# find out if it is operation up or down
for arg in $@; do
    if [ "${arg}" == "up" ]; then
        operation_up=true
        echo "" > .engine.status
    elif [ "${arg}" == "down" ] || [ "${arg}" == "stop" ]; then
        operation_down=true
    fi
done

#unless it's operation down, make sure vm.max_map_count is sufficient and otherwise refuse to continue
if [ "$operation_down" == false ]; then
    let MAXMAP=$(sysctl vm.max_map_count -n)
    if [ $MAXMAP -lt 262144 ]; then
        red=`tput setaf 1`
        yellow=`tput setaf 3`
        reset=`tput sgr0`

       echo "${red}ERROR: max map count is less than 262144. The DIG server backend will not work properly."
       echo "Exiting engine script." 
       echo "Run ${yellow}sudo sysctl -w vm.max_map_count=262144${red} to fix it${reset}"
       exit -1
    fi
fi

if [ "$operation_up" == true ]; then
    # add parameter from env file
    source ./.env
    for arg in $(echo $DIG_ADD_ONS | tr "," "\n"); do
        cmd="$cmd -f docker-compose.${arg}.yml"
        yml="$yml -f docker-compose.${arg}.yml"
    done
else
    # add parameter from .engine.status
    cmd="$cmd $(head -n 1 .engine.status)"
fi

# add parameter from command line
for arg in $@; do
    if [[ "${arg:0:1}" == "+" ]]; then
        arg=${arg:1} # remove plus sign
        cmd="$cmd -f docker-compose.${arg}.yml"
        yml="$yml -f docker-compose.${arg}.yml"
    else
        cmd="$cmd ${arg}"
    fi
done

if [ "$operation_up" == true ]; then
    echo "$yml" > .engine.status
fi

cmd="docker-compose $cmd"
#echo $cmd
eval $cmd