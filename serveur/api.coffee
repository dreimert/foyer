express = require('express')
app     = express()
mongoose = require "mongoose"

User         = mongoose.model "User"
Consommation = mongoose.model "Consommation"

errorHandler = (res) ->
  (err) ->
    res.status(500).send err

sendRep = (res) ->
  (data) ->
    res.send data

app.route '/user'
.get (req, res) ->
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
.get (req, res) ->
  User
  .findOne(login: req.params.login)
  .exec()
  .then sendRep(res), errorHandler(res)

app.route '/consommation'
.get (req, res) ->
  Consommation
  .find()
  .skip(req.query.skip or 0)
  .limit(req.query.limit or 50)
  .exec()
  .then sendRep(res), errorHandler(res)

module.exports = app
