#!/usr/bin/env sh

mkdir -p /run/secrets
MONGODB_USER_ID=${MONGODB_USER_ID:-999}
MONGODB_GROUP_ID=${MONGODB_GROUP_ID:-999}

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

exec "$@"
