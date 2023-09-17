#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 [-m start|control|stop|delete]" 1>&2
    exit 1
fi

CONTROL_MODE=
CONTAINER_ISUP=false        # search by docker ps command
CONTAINER_IS_EXIST=false    # search by docker images command
OPTIONS_ARRAY=("start" "control" "stop" "delete") # management options in array later

# parse option strings
while getopts "m:" OPT
do
    case $OPT in
        m ) echo "choice $OPTARG"
            # verify option mode
            if printf '%s\n' "${OPTIONS_ARRAY[@]}" | grep -qx $OPTARG; then
                echo "control_mode = $OPTARG"
                CONTROL_MODE=$OPTARG
            else
                echo "Usage: $0 [-m start|control|stop|delete]" 1>&2
                exit 1
            fi
            ;;
        * ) echo "Usage: $0 [-m start|control|stop|delete]" 1>&2
            exit 1
            ;;
    esac
done

# check if golang-labo container is existing
docker images | grep golang-labo > /dev/null
if [ $? -eq 0 ]; then
    CONTAINER_IS_EXIST=true
else
    CONTAINER_IS_EXIST=false
fi

# check if golang-labo is running
docker ps | grep golang-labo > /dev/null
if [ $? -eq 0 ]; then
    CONTAINER_ISUP=true
else
    CONTAINER_ISUP=false
fi

# execute according to the options
if [[ $CONTROL_MODE == "start" ]]; then
    if "${CONTAINER_ISUP}"; then
        echo "golang-labo is already running."
    else
        if "${CONTAINER_IS_EXIST}"; then
            echo "container is exist"
        else
            docker-compose build
            echo "container is not exist"
        fi
        docker-compose up -d
        echo "golang-labo start."
    fi
elif [[ $CONTROL_MODE == "control" ]]; then
    if "${CONTAINER_ISUP}"; then
        echo "control golang-labo."
        docker exec -it golang-labo /bin/sh
    else
        echo "golang-labo is not running."
    fi
elif [[ $CONTROL_MODE == "stop" ]]; then
    if "${CONTAINER_ISUP}"; then
        docker-compose stop
        echo "golang-labo stop."
    else
        echo "golang-labo is already stopping."
    fi
elif [[ $CONTROL_MODE == "delete" ]]; then
    if "${CONTAINER_ISUP}"; then
        docker-compose stop
    fi
    docker-compose down --rmi all --volumes --remove-orphans
    echo "delete golang-labo."
fi
