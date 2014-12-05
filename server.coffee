express = require('express')
app     = express()
server  = require('http').Server(app)

bodyParser = require('body-parser')
session = require('express-session')

app.use express.static(__dirname + '/build')

app.use session(secret: 'keyboard cat', cookie: maxAge: 3600000)
app.use bodyParser.json()

db = require("./db")

logged = (req, res, next) ->
  if req.session.logged is true
    next()
  else
    res.sendStatus 401

app.post '/login', (req, res) ->
  db.login req.body.login, req.body.password, (status, data) ->
    console.log "login : ", status, data
    if status is 200
      req.session.logged = true
      req.session.user = data
      res.send data
    else
      res.send status, data

app.get '/search', logged, (req, res) ->
  db.search req.query.search, (status, data) ->
    res.send(status, data)

app.get '/user', logged, (req, res) ->
  db.user req.query.id, (status, data) ->
    res.send(status, data)

app.get '/logged', logged, (req, res) ->
  res.send req.session.user

app.get '/logout', logged, (req, res) ->
  req.session.destroy()
  res.sendStatus(200)

server.listen 3333, () ->
  console.log "Serveur lancé sur le port 3333"
