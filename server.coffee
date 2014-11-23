express = require('express')
app     = express()
server  = require('http').Server(app)

bodyParser = require('body-parser')
session = require('express-session')

app.use express.static(__dirname + '/build')

app.use session(secret: 'keyboard cat', cookie: maxAge: 3600000)
app.use bodyParser.json()

app.post '/login', (req, res) ->
  if req.body.login is "test" and req.body.password is "test"
    req.session.logged = true
    res.send name: "test"
  else
    res.send 401

app.get '/logged', (req, res) ->
  if req.session.logged
    res.send name: "test"
  else
    res.send 401

app.get '/logout', (req, res) ->
  req.session.destroy()
  res.send(200)

server.listen 3333, () ->
  console.log "Serveur lancé sur le port 3333"
