express = require('express')
app     = express()
access  = require "../accessControl"
db      = require "../db"
utils   = require "../utils"
middles = require "../middles"

Promise  = require "bluebird"

app.route '/:lieu'
.get access.rf, middles.getLieu, (req, res) ->
  db().then (connection) ->
    connection.client.query """
      SELECT
        "public"."groupe".nom AS consommable,
        uniteachetee AS quantity,
        prix_adh * uniteachetee AS montant,
        login AS user,
        "public"."consommation".date AS date
      FROM "public"."consommation"
      INNER JOIN "public"."groupeV"
        ON "public"."consommation"."groupeV_id" = "public"."groupeV"."id"
      INNER JOIN "public"."groupe"
        ON "public"."groupeV"."groupe_id" = "public"."groupe"."id"
      LEFT JOIN "public"."utilisateur"
        ON "public"."utilisateur"."ardoise_id" = "public"."consommation"."ardoise_id"
      WHERE lieu_id = #{req.lieuId}
      ORDER BY date DESC
      LIMIT $1::int
      OFFSET $2::int
    """, [(req.query.limit or 10), (req.query.skip or 0)]
  .then (consommations) ->
    res.send(consommations.rows)
  .catch utils.errorHandler("GET consommations", res)
  .finally ->
    @connection.done()
.post(
  access.rf, #TODO check User
  middles.checkUser,
  middles.checkAndParseConsommations,
  middles.registerConsommations,
  (req, res) ->
    res.send req.user
)

app.route '/count/:lieu'
.get access.rf, middles.getLieu, (req, res) ->
  db().then (connection) ->
    connection.client.query """
      SELECT count(*)
      FROM "public"."consommation"
      INNER JOIN "public"."groupeV"
        ON "public"."consommation"."groupeV_id" = "public"."groupeV"."id"
      WHERE lieu_id = #{req.lieuId}
    """
  .then (count) ->
    res.send(count.rows[0].count)
  .catch utils.errorHandler("GET consommations/count", res)
  .finally ->
    @connection.done()

module.exports = app
