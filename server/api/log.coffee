express = require('express')
app     = express()
access  = require "../accessControl"
db      = require "../db"

Promise  = require "bluebird"

app.route '/'
.get access.rf, (req, res) ->
  db().then (connection) ->
    connection.client.query """
      SELECT date, description, nom, prenom
      FROM log
      INNER JOIN utilisateur on utilisateur_id = utilisateur.id
      LIMIT $1::int
      OFFSET $2::int
    """, [(req.query.limit or 50),(req.query.skip or 0)]
  .then (logs) ->
    res.send(logs.rows)
  .catch (err) ->
    console.error "err::logs:", err, err.stack
    res.status(500).send(err)
  .finally ->
    @connection.done()

app.route '/count'
.get access.rf, (req, res) ->
  db().then (connection) ->
    connection.client.query """
      SELECT count(*)
      FROM log
    """
  .then (count) ->
    res.send(count.rows[0].count)
  .catch (err) ->
    console.error "err::logs/count:", err, err.stack
    res.status(500).send(err)
  .finally ->
    @connection.done()

module.exports = app
