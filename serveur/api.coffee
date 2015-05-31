express = require('express')
app     = express()
mongoose = require "mongoose"
access   = require "./accessControl"
Promise  = require "bluebird"

User         = mongoose.model "User"
Consommation = mongoose.model "Consommation"
Consommable  = mongoose.model "Consommable"

lieux = ["foyer", "kfet"]

anonyme = null
User
.findOne login: "anonyme"
.exec()
.then (user) ->
  if user is null
    User.create
      login: "anonyme"
      pass_hash : "pass_hash"
      nom: "anonyme"
      prenom: "anonyme"
      mail: "anonyme@anonyme.com"
    .then (user) ->
      anonyme = user
  else
    anonyme = user

errorHandler = (res) ->
  (err) ->
    res.status(500).send err

sendRep = (res) ->
  (data) ->
    res.send data

checkLieu = (req, res, next) ->
  if lieux.indexOf(req.body.lieu) < 0
    res.status(400).send('no lieu param')
  else
    req.lieu = req.body.lieu
    next()

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

app.route '/me'
.get access.logged, (req, res) ->
  res.send req.session.user

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
      .update {nom: consommation.consommable}, $inc: frigo: -consommation.quantity
      .exec()
  .then () ->
    "ok"
  .then sendRep(res), errorHandler(res)

app.route '/me/consommation'
.get access.logged, (req, res) ->
  Consommation
  .find(user: req.session.user.id)
  .skip(req.query.skip or 0)
  .limit(req.query.limit or 50)
  .sort("-date")
  .exec()
  .then sendRep(res), errorHandler(res)
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
      .update {nom: consommation.consommable}, $inc: frigo: -consommation.quantity
      .exec()
  .then () ->
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
.get (req, res) ->
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
