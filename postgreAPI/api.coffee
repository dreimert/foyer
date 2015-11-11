express = require('express')
app     = express()
conf    = require('../conf')
access  = require "../serveur/accessControl"
db      = require "./db"
utils   = require "./utils"

Promise  = require "bluebird"

lieux = ["foyer", "kfet"]

###
# Middleware
###

checkLieu = (req, res, next) ->
  if lieux.indexOf(req.body.lieu) < 0
    res.status(400).send('no lieu param')
  else
    req.lieu = req.body.lieu
    next()

###
checkAndParseConsommations = (req, res, next) ->
  unless req.body.consommations?
    res.status(400).send('no consommations param')
  else unless Array.isArray(req.body.consommations)
    res.status(400).send('consommations param not an array')
  else if req.body.consommations.length is 0
    res.status(400).send('consommations param is empty')
  else
    Promise.all req.body.consommations.map (consommation) ->
      Consommable
      .findOne nom: consommation.nom
      .exec()
      .then (consommable) ->
        if consommable is null
          return Promise.reject("consommable not found")
        consommable: consommable.nom
        quantity: consommation.quantity
        montant: consommable.prix * consommation.quantity
    .then (consommations) ->
      req.consommations = consommations
      next()
    , (err) ->
      res.status(404).send(err)
###

app.route '/me'
.get access.logged, (req, res) ->
  res.send req.session.user

###
app.route '/anonyme/consommation'
.post checkLieu, checkAndParseConsommations, (req, res) ->
  console.log 'POST /anonyme/consommation'

  Promise.map req.consommations, (consommation) ->
    Consommation
    .create
      consommable: consommation.consommable
      quantity: consommation.quantity
      montant: consommation.montant
      lieu: req.lieu
      user: anonyme.id
  .then (consommations) ->
    montant = consommations.reduce (sum, consommation) ->
      sum += consommation.montant
    , 0

    User
    .findByIdAndUpdate anonyme.id, $inc: montant: montant
    .exec()
    .then (user) ->
      consommations
  .then (consommations) ->
    Promise
    .map consommations, (consommation) ->
      Consommable
      .update {nom: consommation.consommable},
        $inc:
          frigo: -consommation.quantity
      .exec()
  .then () ->
    "ok"
  .then utils.sendHandler(res), utils.errorHandler(res)

app.route '/me/consommation'
.get access.logged, (req, res) ->
  Consommation
  .find(user: req.session.user.id)
  .skip(req.query.skip or 0)
  .limit(req.query.limit or 50)
  .sort("-date")
  .exec()
  .then utils.sendHandler(res), utils.errorHandler(res)
.post access.logged, checkLieu, checkAndParseConsommations, (req, res) ->
  Promise.map req.consommations, (consommation) ->
    Consommation
    .create
      consommable: consommation.consommable
      quantity: consommation.quantity
      montant: consommation.montant
      lieu: req.lieu
      user: req.session.user.id
  .then (consommations) ->
    console.log consommations
    montant = consommations.reduce (sum, consommation) ->
      sum += consommation.montant
    , 0

    User
    .findByIdAndUpdate req.session.user.id, $inc: montant: montant
    .exec()
    .then (user) ->
      req.session.user.montant = user.montant
      consommations
  .then (consommations) ->
    Promise
    .map consommations, (consommation) ->
      Consommable
      .update {nom: consommation.consommable},
        $inc:
          frigo: -consommation.quantity
      .exec()
  .then () ->
    montant: req.session.user.montant
  .then utils.sendHandler(res), utils.errorHandler(res)

app.route '/user'
.get access.rf, (req, res) ->
  if req.query.search?
    regexp = new RegExp(req.query.search, "i")
    User
    .find()
    .or [
      {login:  regexp}
      {nom:    regexp}
      {prenom: regexp}
      {mail:   regexp}
    ]
    .skip(req.query.skip or 0)
    .limit(req.query.limit or 50)
    .sort "nom prenom"
    .exec()
    .then utils.sendHandler(res), utils.errorHandler(res)
  else
    User
    .find()
    .skip(req.query.skip or 0)
    .limit(req.query.limit or 50)
    .sort "nom prenom"
    .exec()
    .then utils.sendHandler(res), utils.errorHandler(res)

app.route '/user/:login'
.get access.rf, (req, res) ->
  User
  .findOne(login: req.params.login)
  .exec()
  .then utils.sendHandler(res), utils.errorHandler(res)

app.route '/consommation'
.get access.rf, (req, res) ->
  Consommation
  .find()
  .skip(req.query.skip or 0)
  .limit(req.query.limit or 50)
  .exec()
  .then utils.sendHandler(res), utils.errorHandler(res)
###

app.route '/consommable'
.get (req, res) ->
  search = ""
  param = []
  if req.query.search
    search = """WHERE nom LIKE $1::text """
    param = ["%#{req.query.search}%"]

  db().bind({}).then (connection) ->
    @connection = connection
    #  mdp_super, , mdp AS pass_hash
    connection.client.query """
      SELECT DISTINCT nom, qte_frigo AS frigo, commentaire,
        (SELECT prix_adh FROM "public"."groupeV"
        WHERE "public"."groupeV"."groupe_id" = "public"."groupe"."id"
        ORDER BY "public"."groupeV".date DESC LIMIT 1) AS prix
      FROM "public"."groupe"
      INNER JOIN stockgroupe on stockgroupe.groupe_id = "public"."groupe".id
      #{search}
      ORDER BY prix
    """, param
  .then (consommables) ->
    res.send(consommables.rows)
    @connection.done()
  , (err) ->
    console.error "err::", err
    res.status(500).send(err)

module.exports = app
