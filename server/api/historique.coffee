express = require('express')
app     = express()
access  = require "../accessControl"
db      = require "../db"
utils   = require "../utils"
middles = require "../middles"

Promise  = require "bluebird"

app.route '/'
.get access.rf, (req, res) ->
  db().then (connection) ->
    connection.client.query """
      SELECT *
      FROM log
      ORDER BY date DESC
      LIMIT $1::int
      OFFSET $2::int
    """, [(req.query.limit or 10), (req.query.skip or 0)]
  .then (log) ->
    res.send(log.rows)
  .catch utils.errorHandler("GET historique", res)
  .finally ->
    @connection.done()

app.route '/count'
.get access.rf, (req, res) ->
  db().then (connection) ->
    connection.client.query """
      SELECT count(*)
      FROM "public"."log"
    """
  .then (count) ->
    res.send(count.rows[0].count)
  .catch utils.errorHandler("GET historique/count", res)
  .finally ->
    @connection.done()

module.exports = app
