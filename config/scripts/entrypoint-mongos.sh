#!/usr/bin/env sh

# Add configsvr address to confiration file
stack_name=`echo -n $(/opt/rancher/bin/curl http://rancher-metadata/latest/self/stack/name)`
configsvr_members=$(/opt/rancher/bin/curl http://rancher-metadata/latest/stacks/$stack_name/services/configsvr/containers)
members=""
for member in $configsvr_members
do
  member_index=$(echo $member | tr '=' '\n' | head -n1)
  member_ip=$(/opt/rancher/bin/curl http://rancher-metadata/latest/stacks/$stack_name/services/configsvr/containers/$member_index/primary_ip)
  members="$members,$member_ip:27017"
done
members=$(echo "$members" | sed 's/,//')

if [ ! -f /data/db/.metadata/.router ]
  then
  mongos --fork --logpath /var/log/mongod.log --port 27017 --keyFile /run/secrets/MONGODB_KEYFILE --configdb $CONFIGSVR_RS_NAME/$members
  RET=1
  while [ $RET != 0 ]
  do
    echo "=> Waiting for confirmation of MongoDB service startup"
    sleep 5
    mongo admin --eval "help" >/dev/null 2>&1
    RET=$?
  done

  # Get ip of master replicaset
  master_ip=$(/opt/rancher/bin/curl http://rancher-metadata/latest/stacks/$stack_name/services/mongod/containers/0/primary_ip)
  # Apply sharding configuration
  mongo --eval "printjson(sh.addShard('$MONGOD_RS_NAME/$master_ip:27017'))"

  # Enable admin account
  MONGODB_DBNAME=${MONGODB_DBNAME:-mydb}
  mongo <<EOF
admin = db.getSiblingDB('admin')
admin.auth('$MONGO_INITDB_ROOT_USERNAME', '$MONGO_INITDB_ROOT_PASSWORD')
admin.grantRolesToUser(
  '$MONGO_INITDB_ROOT_USERNAME',
  [ { role: 'root', db: 'admin' }, { role: 'clusterManager', db: 'admin' }, { role: "userAdminAnyDatabase", db: "admin" }, { role: 'dbOwner', db: '$MONGODB_DBNAME' } ]
)
mydb = db.getSiblingDB('$MONGODB_DBNAME')
mydb.createUser(
  {
    user: '$MONGO_INITDB_ROOT_USERNAME',
    pwd: '$MONGO_INITDB_ROOT_PASSWORD',
    roles: [ { role: 'dbOwner', db: '$MONGODB_DBNAME' } ]
  }
)
EOF
  mkdir -p /data/db/.metadata
  touch /data/db/.metadata/.router
  mongo -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD admin --eval "printjson(db.shutdownServer())" && mongos --port 27017 --keyFile /run/secrets/MONGODB_KEYFILE --configdb $CONFIGSVR_RS_NAME/$members
else
  mongos --port 27017 --keyFile /run/secrets/MONGODB_KEYFILE --configdb $CONFIGSVR_RS_NAME/$members
fi
