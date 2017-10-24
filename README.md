# MongoDB Sharded Rancher

Rancher template for MongoDB Sharded

## Install

In Rancher's UI, go to **Admin/Settings** and add a new custom catalog:

| Name            | URL                                                   | Branch |
| --------------- | ----------------------------------------------------- | ------ |
| MongoDB Sharded | https://github.com/lgaticaq/mongo-sharded-rancher.git | master |

## Templates

* **mongodb**: MongoDB Sharded for production environment

## Docker Images

* **mongodb-sharded-config**:
Docker image used as sidekick container of all mongodb containers to provide secrets and scripts.
