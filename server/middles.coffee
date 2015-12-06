db      = require "./db"
utils   = require "./utils"
Promise = require "bluebird"

lieux =
  foyer: 4
  kfet: 5

anonyme = null

db().then ->
  @connection.client.query """
    SELECT *
    FROM "public"."ardoise"
    WHERE id = 0
  """
.then (user) ->
  if user.rows[0]?
    anonyme = user.rows[0]
  else
    @connection.client.query """
      INSERT INTO ardoise ("id", "montant")
      VALUES (0, 0)
    """
.then ->
  @connection.client.query """
    SELECT *
    FROM "public"."ardoise"
    WHERE id = 0
  """
.then (user) ->
  if user.rows[0]?
    anonyme = user.rows[0]
  else
    Promise.reject "anonyme not existe and not create"
.catch (err) ->
  console.error "ERROR::createAnonyme:", err
.finally ->
  @connection.done()

module.exports =
  requireLieu: (req, res, next) ->
    if lieux.indexOf(req.body.lieu) < 0
      res.status(400).send('no lieu param')
    else
      req.lieu = req.body.lieu
      next()

  getLieu: (req, res, next) ->
    unless lieux[req.params.lieu]?
      res.status(400).send('no lieu param')
    else
      req.lieuId = lieux[req.params.lieu]
      next()

  checkAndParseConsommations: (req, res, next) ->
    unless req.body.consommations?
      res.status(400).send('no consommations param')
    else unless Array.isArray(req.body.consommations)
      res.status(400).send('consommations param not an array')
    else if req.body.consommations.length is 0
      res.status(400).send('consommations param is empty')
    else
      db().then (connection) ->
        Promise.all req.body.consommations.map (consommation) =>
          @connection.client.query """
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
        next()
      .catch utils.errorHandler("checkAndParseConsommations", res)
      .finally ->
        @connection.done()

  registerConsommations: (req, res, next) ->
    db().then (connection) ->
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
      @connection.client.query 'COMMIT'
      next()
    .catch utils.errorHandler "checkAndParseConsommations", res, ->
      @connection.client.query 'ROLLBACK'
    .finally ->
      @connection.done()

  setAnonyme: (req, res, next) ->
    req.session.logged = false
    req.session.user = anonyme
    next()
