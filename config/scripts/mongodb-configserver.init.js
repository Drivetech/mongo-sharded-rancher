rs.initiate(
  {
    _id: 'mongodb-configserver',
    configsvr: true,
    version: 1,
    members: [
      { _id: 0, host : 'configsvr-1:27017' },
      { _id: 1, host : 'configsvr-2:27017' },
      { _id: 2, host : 'configsvr-3:27017' }
    ]
  }
)
