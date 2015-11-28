express = require('express')
app     = express()
access  = require "../../serveur/accessControl"
db      = require "../db"
utils   = require "../utils"

Promise  = require "bluebird"

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

app.use '/me', require './me'
app.use '/consommable', require './consommable'

module.exports = app
