express = require('express')
app     = express()
access  = require "../accessControl"
db      = require "../db"
utils   = require "../utils"
middles = require "../middles"

Promise  = require "bluebird"

app.route '/:lieu'
.get access.rf, middles.getLieu, (req, res) ->
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
      WHERE lieu_id = #{req.lieuId}
      #{search}
      ORDER BY #{utils.order(["nom", "qte_frigo", "nomreduit"], ["nom", "nomreduit"], req.query.order, "nom")}
      LIMIT $1::int
      OFFSET $2::int
    """, [(req.query.limit or 10), (req.query.skip or 0)].concat(params)
  .then (consommations) ->
    console.log consommations.rows
    res.send(consommations.rows)
  .catch utils.errorHandler("GET frigo", res)
  .finally ->
    @connection.done()

app.route '/count/:lieu'
.get access.rf, middles.getLieu, (req, res) ->
  db().then (connection) ->
    connection.client.query """
      SELECT count(*)
      FROM "public"."stockgroupe"
      WHERE lieu_id = #{req.lieuId}
    """
  .then (count) ->
    res.send(count.rows[0].count)
  .catch utils.errorHandler("GET frigo/count", res)
  .finally ->
    @connection.done()

module.exports = app
