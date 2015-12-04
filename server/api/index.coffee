express = require('express')
app     = express()
access  = require "../../serveur/accessControl"
db      = require "../db"
utils   = require "../utils"

Promise  = require "bluebird"

###
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

###

app.use '/anonyme', require './anonyme'
app.use '/me', require './me'
app.use '/consommable', require './consommable'
app.use '/consommation', require './consommation'

module.exports = app
