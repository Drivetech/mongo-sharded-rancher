#!/usr/bin/env sh

mongod --fork --logpath /var/log/mongod.log --keyFile /run/secrets/MONGODB_KEYFILE --replSet $RS_NAME --shardsvr --dbpath /data/db --port 27017
apt-get update && apt-get install -y --no-install-recommends wget && rm -rf /var/lib/apt/lists/*
MYIP=$(/opt/rancher/bin/giddyup ip myip)
stack_name=`echo -n $(wget -q -O - http://rancher-metadata/latest/self/stack/name)`
mongod_members=$(wget -q -O - http://rancher-metadata/latest/stacks/$stack_name/services/mongod/containers)
members=""
for member in $mongod_members
do
  member_index=$(echo $member | tr '=' '\n' | head -n1)
  IP=$(wget -q -O - http://rancher-metadata/latest/stacks/$stack_name/services/mongod/containers/$member_index/primary_ip)
  IS_MASTER=$(mongo --host $IP --eval "printjson(db.isMaster())" | grep 'ismaster')
  if echo $IS_MASTER | grep "true"
  then
    mongo --host $IP -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin --eval "printjson(rs.addArb('$MYIP:27017'))"
  fi
done
mongod --shutdown && mongod --keyFile /run/secrets/MONGODB_KEYFILE --replSet $RS_NAME --shardsvr --dbpath /data/db --port 27017
