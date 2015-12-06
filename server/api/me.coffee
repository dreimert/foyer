express = require('express')
app     = express()
access  = require "../accessControl"
db      = require "../db"
utils   = require "../utils"
middles = require "../middles"

Promise  = require "bluebird"

app.route '/'
.get access.logged, (req, res) ->
  res.send req.session.user

app.route '/consommation'
.get access.logged, (req, res) ->
  db().then (connection) ->
    connection.client.query """
      SELECT
        nom AS consommable,
        uniteachetee AS quantity,
        prix_adh * uniteachetee AS montant,
        ardoise_id AS ardoise,
        "public"."consommation".date AS date
      FROM "public"."consommation"
      INNER JOIN "public"."groupeV"
        ON "public"."consommation"."groupeV_id" = "public"."groupeV"."id"
      INNER JOIN "public"."groupe"
        ON "public"."groupeV"."groupe_id" = "public"."groupe"."id"
      WHERE ardoise_id = #{req.session.user.id}
      ORDER BY date DESC
      LIMIT $1::int
      OFFSET $2::int
    """, [(req.query.limit or 10), (req.query.skip or 0)]
  .then (consommables) ->
    res.send(consommables.rows)
  .catch utils.errorHandler("GET consommations", res)
  .finally ->
    @connection.done()
.post(
  access.logged,
  middles.checkAndParseConsommations,
  middles.registerConsommations,
  utils.sendUserHandler
)

app.route '/consommation/count'
.get access.logged, (req, res) ->
  db().then (connection) ->
    connection.client.query """
      SELECT count(*)
      FROM "public"."consommation"
      WHERE ardoise_id = #{req.session.user.id}
    """
  .then (count) ->
    res.send(count.rows[0].count)
  .catch utils.errorHandler("GET consommation/count", res)
  .finally ->
    @connection.done()

module.exports = app
