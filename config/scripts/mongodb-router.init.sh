#!/bin/bash

set -m

mongos --port 27017 --keyFile /run/secrets/MONGODB_KEYFILE --configdb mongodb-configserver/configsvr-1:27017,configsvr-2:27017,configsvr-3:27017 &

RET=1
while [[ RET -ne 0 ]]; do
  echo "=> Waiting for confirmation of MongoDB service startup"
  sleep 5
  mongo admin --eval "help" >/dev/null 2>&1
  RET=$?
done

# Apply sharding configuration
mongo < /opt/mongodb/scripts/mongodb-sharding.init.js

# Enable admin account
MONGODB_PASSWORD_ADMIN_USER=$(cat /run/secrets/MONGODB_PASSWORD_ADMIN_USER)
MONGODB_ADMIN_USER=${MONGODB_ADMIN_USER:-admin}
MONGODB_DBNAME=${MONGODB_DBNAME:-mydb}
mongo <<EOF
admin = db.getSiblingDB('admin')
admin.createUser(
  {
    user: '$MONGODB_ADMIN_USER',
    pwd: '$MONGODB_PASSWORD_ADMIN_USER',
    roles: [ { role: 'clusterManager', db: 'admin' }, { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)
admin.auth('$MONGODB_ADMIN_USER', '$MONGODB_PASSWORD_ADMIN_USER')
admin.grantRolesToUser(
  '$MONGODB_ADMIN_USER',
  [ { role: 'root', db: 'admin' }, { role: 'dbOwner', db: '$MONGODB_DBNAME' } ]
)
mydb = db.getSiblingDB('$MONGODB_DBNAME')
mydb.createUser(
  {
    user: '$MONGODB_ADMIN_USER',
    pwd: '$MONGODB_PASSWORD_ADMIN_USER',
    roles: [ { role: 'dbOwner', db: '$MONGODB_DBNAME' } ]
  }
)
EOF

fg
