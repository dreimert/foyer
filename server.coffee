express = require('express')
app     = express()

bodyParser = require('body-parser')
session = require('express-session')

app.use express.static(__dirname + '/build')

app.use session(secret: 'keyboard cat', cookie: maxAge: 3600000)
app.use bodyParser.json()

db = require("./db")

app.use require './login'

# after here, the user must be login

app.get '/search', (req, res) ->
  db.search req.query.search, (status, data) ->
    res.send(status, data)

app.get '/user', (req, res) ->
  db.user req.query.id, (status, data) ->
    res.send(status, data)

app.listen 3333, () ->
  console.log "Serveur lancé sur le port 3333"
