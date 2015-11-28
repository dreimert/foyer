express = require('express')
app     = express()
access  = require "../../serveur/accessControl"
db      = require "../db"
utils   = require "../utils"
middles = require "../middles"

Promise  = require "bluebird"

checkAndParseConsommations = (req, res, next) ->
  unless req.body.consommations?
    res.status(400).send('no consommations param')
  else unless Array.isArray(req.body.consommations)
    res.status(400).send('consommations param not an array')
  else if req.body.consommations.length is 0
    res.status(400).send('consommations param is empty')
  else
    db().bind({}).then (connection) ->
      @connection = connection

      Promise.all req.body.consommations.map (consommation) ->
        connection.client.query """
          SELECT
            *,
            "public"."groupe".id AS groupe_id,
            "public"."groupeV".id AS groupeV_id,
            $2::int AS quantity
          FROM "public"."groupeV"
          INNER JOIN "public"."groupe"
            ON "public"."groupeV"."groupe_id" = "public"."groupe"."id"
          WHERE "public"."groupeV".id = $1::int
        """, [consommation.id, consommation.quantity]
        .then (rep) ->
          rep.rows[0]
    .then (consommations) ->
      req.consommations = consommations
      @connection.done()
      next()
    , (err) ->
      console.error "middles::err:", err
      res.status(500).send(err)

app.route '/'
.get access.logged, (req, res) ->
  res.send req.session.user

app.route '/consommation'
.get access.logged, (req, res) ->
  db().bind({}).then (connection) ->
    @connection = connection

    connection.client.query """
      SELECT
        nom AS consommable,
        uniteachetee AS quantity,
        prix_adh * uniteachetee AS montant,
        'foyer' AS lieu,
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
    """, [(req.query.limit or 50), (req.query.skip or 0)]
  .then (consommables) ->
    res.send(consommables.rows)
    @connection.done()
  , (err) ->
    console.error "consommation::err:", err
    res.status(500).send(err)
.post access.logged, middles.requireLieu, checkAndParseConsommations, (req, res) ->
  db().bind({}).then (connection) ->
    @connection = connection
    @connection.client.query 'BEGIN'
  .then ->
    Promise.map req.consommations, (consommation) =>
      @connection.client.query """
        INSERT INTO consommation ("groupeV_id", uniteachetee, ardoise_id)
        VALUES ($1::int, $2::int, $3::int)
      """, [consommation.groupev_id, consommation.quantity, req.session.user.id]
  .then () ->
    req.montant = req.consommations.reduce (sum, consommation) ->
      sum += consommation.quantity * consommation.prix_adh
    , 0
  .then ->
    # Update frigo
    Promise.map req.consommations, (consommation) =>
      @connection.client.query """
        UPDATE stockgroupe SET qte_frigo = qte_frigo - $1::int
        WHERE stockgroupe.groupe_id = $2::int
      """, [consommation.quantity, consommation.groupe_id]
  .then ->
    # update user
    @connection.client.query """
      UPDATE "public"."ardoise" SET montant = montant + $1
      WHERE id = $2::int
      RETURNING montant
    """, [req.montant, req.session.user.id]
  .then (montant) ->
    req.session.user.montant = parseFloat montant.rows[0].montant
    res.send
      montant: req.session.user.montant

    @connection.client.query 'COMMIT'
  .catch (err) ->
    console.log "post me/consommation", err
    res.status(500).send(err)
    @connection.client.query 'ROLLBACK'
  .finally ->
    @connection.done()

module.exports = app
