#!/bin/sh

mkdir -p /run/secrets
MONGODB_USER_ID=${MONGODB_USER_ID:-999}
MONGODB_GROUP_ID=${MONGODB_GROUP_ID:-999}

tr -cd '[:alnum:]' < /dev/urandom | fold -w775 | head -n1 > /run/secrets/MONGODB_KEYFILE
tr -cd '[:alnum:]' < /dev/urandom | fold -w32 | head -n1 > /run/secrets/MONGODB_PASSWORD_ADMIN_USER
chmod 400 /run/secrets/MONGODB_KEYFILE /run/secrets/MONGODB_PASSWORD_ADMIN_USER
chown $MONGODB_USER_ID:$MONGODB_GROUP_ID /run/secrets/MONGODB_KEYFILE /run/secrets/MONGODB_PASSWORD_ADMIN_USER
IFS="
"
for ENV_VAR in `env`; do
  ENV_VAR=`echo "$ENV_VAR" | sed -e 's,=.*,,'`
  echo $ENV_VAR | grep -q "_SECRET$" || continue
  SECRET_FILE=`echo "$ENV_VAR" | sed -e 's,_SECRET$,,g'`
  printenv $ENV_VAR > /run/secrets/$SECRET_FILE
  echo "Providing secrets for $ENV_VAR in /run/secrets/$SECRET_FILE"
  chmod 400 /run/secrets/$SECRET_FILE
  chown $MONGODB_USER_ID:$MONGODB_GROUP_ID /run/secrets/$SECRET_FILE
done
