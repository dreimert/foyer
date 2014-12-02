express = require('express')
app     = express()
server  = require('http').Server(app)
mysql   = require('mysql')

bodyParser = require('body-parser')
session = require('express-session')

app.use express.static(__dirname + '/build')

app.use session(secret: 'keyboard cat', cookie: maxAge: 3600000)
app.use bodyParser.json()

sql = require("./sql.conf")

connection = mysql.createConnection sql.config

connection.connect()

logged = (req, res, next) ->
  if req.session.logged is true
    next()
  else
    res.send 401

app.post '/login', (req, res) ->
  sql.login connection, req.body.login, req.body.password, (err, user) ->
    if err?
      res.send 500
    else if user?
      req.session.logged = true
      req.session.user = user
      res.send name: user.personne_prenom
    else
      res.send 401

app.get '/search', logged, (req, res) ->
  console.log "req.query :", req.query
  sql.search connection, req.query.search, (err, users) ->
    if err?
      res.send 500
      console.error err
    else
      res.send users

app.get '/logged', logged, (req, res) ->
  res.send name: "test"

app.get '/logout', logged, (req, res) ->
  req.session.destroy()
  res.send(200)

server.listen 3333, () ->
  console.log "Serveur lancé sur le port 3333"
