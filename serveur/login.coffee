express = require('express')
app     = express()
db = require("./db")

logged = (req, res, next) ->
  if req.session.logged is true
    next()
  else
    res.sendStatus 401

app.post '/login', (req, res) ->
  db.login(req.body.login, req.body.password)
  .then (data) ->
    console.log "login : ", data
    req.session.logged = true
    req.session.user = data
    db.getRoles(req.session.user.id)
  .then (roles) ->
    req.session.user.roles = roles
    res.send req.session.user
  , (err) ->
    res.status(err.status).send err.msg

app.use logged

app.get '/logged', (req, res) ->
  res.send req.session.user

app.get '/logout', (req, res) ->
  req.session.destroy()
  res.sendStatus(200)

module.exports = app
