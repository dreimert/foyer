express = require('express')
app     = express()
mongoose = require "mongoose"
access   = require "./accessControl"
Promise  = require "bluebird"

User         = mongoose.model "User"
Consommation = mongoose.model "Consommation"
Consommable  = mongoose.model "Consommable"

errorHandler = (res) ->
  (err) ->
    res.status(500).send err

sendRep = (res) ->
  (data) ->
    res.send data

app.route '/me'
.get access.logged, (req, res) ->
  res.send req.session.user

app.route '/me/consommation'
.get access.logged, (req, res) ->
  Consommation
  .find(user: req.session.user.id)
  .skip(req.query.skip or 0)
  .limit(req.query.limit or 50)
  .sort("-date")
  .exec()
  .then sendRep(res), errorHandler(res)
.post access.logged, (req, res) ->
  console.log 'POST /me/consommation'
  unless req.body.consommations?
    res.sendStatus(400)
  else
    Promise.all req.body.consommations.map (consommation) ->
      Consommable
      .findOne nom: consommation.nom
      .exec()
      .then (consommable) ->
        consommable: consommable
        consommation: consommation
    .then (results) ->
      console.log "results", results
      Promise.map results, (result) ->
        console.log "result :", result
        console.log "montant :", result.consommable.prix * result.consommation.quantity
        Consommation
        .create
          consommable: result.consommable.nom
          quantity: result.consommation.quantity
          montant: result.consommable.prix * result.consommation.quantity
          lieu: "foyer"
          user: req.session.user.id
    .then (consommations) ->
      console.log consommations
      montant = consommations.reduce (sum, consommation) ->
        sum += consommation.montant
      , 0
      console.log "montant", montant
      console.log "req.session.user.id", req.session.user.id
      User
      .findByIdAndUpdate req.session.user.id, $inc: montant: montant
      .exec()
      .then (user) ->
        console.log "user", user
        req.session.user.montant = user.montant
        consommations
      .then (consommations) ->
        console.log consommations
        Promise
        .map consommations, (consommation) ->
          Consommable
          .update {nom: consommation.consommable}, $inc: frigo: -consommation.quantity
          .exec()
      .then () ->
        console.log "send Montant"
        montant: req.session.user.montant
    .then sendRep(res), errorHandler(res)

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
    .then sendRep(res), errorHandler(res)
  else
    User
    .find()
    .skip(req.query.skip or 0)
    .limit(req.query.limit or 50)
    .sort "nom prenom"
    .exec()
    .then sendRep(res), errorHandler(res)

app.route '/user/:login'
.get access.rf, (req, res) ->
  User
  .findOne(login: req.params.login)
  .exec()
  .then sendRep(res), errorHandler(res)

app.route '/consommation'
.get access.rf, (req, res) ->
  Consommation
  .find()
  .skip(req.query.skip or 0)
  .limit(req.query.limit or 50)
  .exec()
  .then sendRep(res), errorHandler(res)

app.route '/consommable'
.get access.logged, (req, res) ->
  search = {}
  if req.query.search
    search.nom = new RegExp req.query.search, "i"
  Consommable
  .find(search)
  .skip(req.query.skip or 0)
  .limit(req.query.limit)
  .sort("prix")
  .exec()
  .then sendRep(res), errorHandler(res)

module.exports = app
