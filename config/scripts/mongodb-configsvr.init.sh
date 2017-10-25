#!/bin/bash

set -m

mongod --configsvr --dbpath /data/db --port 27017 --keyFile /run/secrets/MONGODB_KEYFILE --replSet mongodb-configserver &

if [ ! -f /data/db/.metadata/.configsvr ]; then
  RET=1
  while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MongoDB service startup"
    sleep 5
    mongo admin --eval "help" >/dev/null 2>&1
    RET=$?
  done

  # Config servers setup
  mongo < /opt/mongodb/scripts/mongodb-configserver.init.js

  mkdir -p /data/db/.metadata
  touch /data/db/.metadata/.configsvr
fi

fg
