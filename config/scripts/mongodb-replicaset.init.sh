#!/bin/bash

set -m

mongod --keyFile /run/secrets/MONGODB_KEYFILE --replSet rs1 --shardsvr --dbpath /data/db --port 27017 &

RET=1
while [[ RET -ne 0 ]]; do
  echo "=> Waiting for confirmation of MongoDB service startup"
  sleep 5
  mongo admin --eval "help" >/dev/null 2>&1
  RET=$?
done

# Replicaset servers setup
mongo < /opt/mongodb/scripts/mongodb-replicaset.init.js

fg
