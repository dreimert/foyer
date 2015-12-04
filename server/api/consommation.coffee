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
      ORDER BY date DESC
      LIMIT $1::int
      OFFSET $2::int
    """, [(req.query.limit or 50), (req.query.skip or 0)]
  .then (consommations) ->
    res.send(consommations.rows)
  .catch utils.errorHandler("GET consommations", res)
  .finally ->
    @connection.done()

module.exports = app
