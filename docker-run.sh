#!/bin/bash

export ENV_SRC=" "

if [ -f ./.env ]; then
    source ./.env
    export ENV_SRC=" --env-file ./.env "
else
    if [ -f ./src/.env ]; then
        source ./src/.env
        export ENV_SRC=" --env-file ./src/.env "
    fi
fi

export APP_SERVICE=${APP_SERVICE:-larvel_app}

# docker exec -it $APP_SERVICE $@

docker exec -it --user=root $APP_SERVICE /bin/sh
