express = require('express')
app     = express()
access  = require "../accessControl"
db      = require "../db"
utils   = require "../utils"
middles = require "../middles"

Promise  = require "bluebird"

app.route '/'
.get access.rf, (req, res) ->
  params = []
  search = ""
  if req.query.search
    search = "AND lower(nom) LIKE $3::text"
    params = ["%#{req.query.search.toLowerCase()}%"]
  db().then (connection) ->
    connection.client.query """
      SELECT *
      FROM stockgroupe
      INNER JOIN groupe on groupe.id = stockgroupe.groupe_id
      WHERE lieu_id = 4
      #{search}
      ORDER BY nom
      LIMIT $1::int
      OFFSET $2::int
    """, [(req.query.limit or 10), (req.query.skip or 0)].concat(params)
  .then (consommations) ->
    res.send(consommations.rows)
  .catch utils.errorHandler("GET frigo", res)
  .finally ->
    @connection.done()

app.route '/count'
.get access.rf, (req, res) ->
  db().then (connection) ->
    connection.client.query """
      SELECT count(*)
      FROM "public"."stockgroupe"
    """
  .then (count) ->
    res.send(count.rows[0].count)
  .catch utils.errorHandler("GET frigo/count", res)
  .finally ->
    @connection.done()

module.exports = app
