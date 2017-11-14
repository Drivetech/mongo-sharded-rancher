#!/usr/bin/env sh

/opt/rancher/bin/giddyup leader check
if [ "$?" -eq "0" ]
then
  echo "This is the lowest numbered contianer.. Handling the initiation."
  if [ ! -f /data/db/.metadata/.replicaset ]; then
    mongod --fork --dbpath /data/db --port 27017 --logpath /var/log/mongod.log
    RET=1
    while [ $RET -ne 0 ]
    do
      echo "=> Waiting for confirmation of MongoDB service startup"
      sleep 5
      mongo admin --eval "help" >/dev/null 2>&1
      RET=$?
    done

    mongo admin --eval "db.createUser({user:'$MONGO_INITDB_ROOT_USERNAME',pwd:'$MONGO_INITDB_ROOT_PASSWORD',roles:[{role:'root',db:'admin'}]})"
    mongod --shutdown && mongod --fork --logpath /var/log/mongod.log --keyFile /run/secrets/MONGODB_KEYFILE --replSet $RS_NAME --shardsvr --dbpath /data/db --port 27017
    echo "Replicaset servers setup"
    MYIP=$(/opt/rancher/bin/giddyup ip myip)
    CONFIG="{_id:\"$RS_NAME\",version:1,members:[{_id:0,host:\"$MYIP:27017\"}]}"
    mongo -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin --eval "printjson(rs.initiate($CONFIG))"
    for member in $(/opt/rancher/bin/giddyup ip stringify --delimiter " "); do
      if [ "$member" != "$MYIP" ]; then
        mongo -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin --eval "printjson(rs.add('$member:27017'))"
        sleep 5
      fi
    done

    mkdir -p /data/db/.metadata
    touch /data/db/.metadata/.replicaset
    mongod --shutdown && mongod --keyFile /run/secrets/MONGODB_KEYFILE --replSet $RS_NAME --shardsvr --dbpath /data/db --port 27017
  else
    mongod --keyFile /run/secrets/MONGODB_KEYFILE --replSet $RS_NAME --shardsvr --dbpath /data/db --port 27017
  fi
else
  mongod --fork --logpath /var/log/mongod.log --keyFile /run/secrets/MONGODB_KEYFILE --replSet $RS_NAME --shardsvr --dbpath /data/db --port 27017
  MYIP=$(/opt/rancher/bin/giddyup ip myip)
  for IP in $(/opt/rancher/bin/giddyup ip stringify --delimiter " ")
  do
    IS_MASTER=$(mongo --host $IP --eval "printjson(db.isMaster())" | grep 'ismaster')
    if echo $IS_MASTER | grep "true"
    then
      mongo --host $IP -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase admin --eval "printjson(rs.add('$MYIP:27017'))"
    fi
  done
  mongod --shutdown && mongod --keyFile /run/secrets/MONGODB_KEYFILE --replSet $RS_NAME --shardsvr --dbpath /data/db --port 27017
fi
