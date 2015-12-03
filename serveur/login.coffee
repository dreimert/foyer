express = require('express')
app     = express()
mongoose = require 'mongoose'
access   = require "./accessControl"

User = mongoose.model "User"

app.post '/login', (req, res) ->
  User
  .findOne(login:req.body.login)
  .exec()
  .then (user) ->
    if user is null
      res.status(404).send()
    else if user.authenticate req.body.password
      req.session.logged = true
      req.session.user =
        id: user._id
        login: user.login
        nom: user.nom
        prenom: user.prenom
        roles: user.roles.map (role) -> role.name
        montant: user.montant
      res.send req.session.user
    else
      res.status(404).send()
  , (err) ->
    res.status(500).send(err)

app.get '/logged', access.logged, (req, res) ->
  res.send req.session.user

app.get '/logout', access.logged, (req, res) ->
  req.session.destroy()
  res.sendStatus(200)

app.post '/loginRf', access.logged, (req, res) ->
  User
  .findOne(_id: req.session.user.id)
  .exec()
  .then (user) ->
    if user is null
      res.status(404).send()
    else if user.authenticateWithRole("rf", req.body.password)
      req.session.user.loginRf = true
      res.send true
    else
      res.status(404).send()
  .then null, (err) ->
    res.status(500).send(err)

module.exports = app
