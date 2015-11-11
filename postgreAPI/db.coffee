conf    = require('../conf')
Pgb     = require("pg-bluebird")
pgb     = new Pgb()

connection = () ->
  pgb.connect(conf.db.pg)

connection().then (connection) ->
  connection.done()
.catch (err) ->
  console.error "DB::err:", err

module.exports = connection
