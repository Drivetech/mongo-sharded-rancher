#!/bin/sh

mkdir -p /run/secrets

tr -cd '[:alnum:]' < /dev/urandom | fold -w775 | head -n1 > /run/secrets/MONGODB_KEYFILE_SECRET
tr -cd '[:alnum:]' < /dev/urandom | fold -w32 | head -n1 > /run/secrets/MONGODB_PASSWORD_ADMIN_USER_SECRET
tr -cd '[:alnum:]' < /dev/urandom | fold -w32 | head -n1 > /run/secrets/MONGODB_PASSWORD_ROOT_USER_SECRET
IFS="
"
for ENV_VAR in `env`; do
    ENV_VAR=`echo "$ENV_VAR" | sed -e 's,=.*,,'`
    echo $ENV_VAR | grep -q "_SECRET$" || continue
    SECRET_FILE=`echo "$ENV_VAR" | sed -e 's,_SECRET$,,g'`
    printenv $ENV_VAR > /run/secrets/$SECRET_FILE
    echo "Providing secrets for $ENV_VAR in /run/secrets/$SECRET_FILE"
done