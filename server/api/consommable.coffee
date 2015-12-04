express = require('express')
app     = express()
access  = require "../accessControl"
db      = require "../db"
utils   = require "../utils"
middles = require "../middles"

Promise  = require "bluebird"

app.route '/:lieu'
.get middles.getLieu, (req, res) ->
  search = ""
  param = []
  if req.query.search
    search = """AND nom LIKE $1::text """
    param = ["%#{req.query.search}%"]

  db().then (connection) ->
    #  mdp_super, , mdp AS pass_hash
    connection.client.query """
      SELECT "public"."groupeV".id AS id, nom, prix_adh AS prix
      FROM "public"."groupe"
      INNER JOIN "public"."groupeV"
        ON "public"."groupeV".groupe_id = "public"."groupe".id
      WHERE actif = true
      AND lieu_id = #{req.lieuId}
      #{search}
      ORDER BY prix
    """, param
  .then (consommables) ->
    res.send(consommables.rows)
  .catch (err) ->
    console.error "err::consommables:", err
    res.status(500).send(err)
  .finally ->
    @connection.done()

module.exports = app
