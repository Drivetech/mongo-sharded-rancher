rs.initiate(
  {
    _id: 'rs1',
    version: 1,
    members: [
      { _id: 0, host : 'primary:27017' },
      { _id: 1, host : 'secundary:27017' },
      { _id: 2, host : 'arbiter:27017', arbiterOnly: true }
    ]
  }
)
