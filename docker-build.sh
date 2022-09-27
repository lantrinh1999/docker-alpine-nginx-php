#!/bin/bash

export ENV_SRC=" "
if [ -f ./src/.env ]; then
    source ./src/.env
    export ENV_SRC=" --env-file ./src/.env "
else
    if [ -f ./.env ]; then
        source ./.env
        export ENV_SRC=" --env-file ./.env "
    fi
fi

export APP_SERVICE=${APP_SERVICE:-larvel_app}

docker-compose -p $APP_SERVICE $ENV_SRC build
