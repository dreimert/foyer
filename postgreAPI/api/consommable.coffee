express = require('express')
app     = express()
access  = require "../../serveur/accessControl"
db      = require "../db"
utils   = require "../utils"

Promise  = require "bluebird"

app.route '/'
.get (req, res) ->
  search = ""
  param = []
  if req.query.search
    search = """AND nom LIKE $1::text """
    param = ["%#{req.query.search}%"]

  db().bind({}).then (connection) ->
    @connection = connection
    #  mdp_super, , mdp AS pass_hash
    connection.client.query """
      SELECT "public"."groupeV".id AS id, nom, prix_adh AS prix
      FROM "public"."groupe"
      INNER JOIN "public"."groupeV"
        ON "public"."groupeV".groupe_id = "public"."groupe".id
      WHERE actif = true
      #{search}
      ORDER BY prix
    """, param
  .then (consommables) ->
    res.send(consommables.rows)
    @connection.done()
  , (err) ->
    console.error "err::consommables:", err
    res.status(500).send(err)

module.exports = app
