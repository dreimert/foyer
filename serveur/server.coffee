express = require('express')
app     = express()

bodyParser = require('body-parser')
session = require('express-session')

app.use express.static(__dirname + '/../build')

app.use session(secret: 'keyboard cat', cookie: maxAge: 3600000)
app.use bodyParser.json()

db = require("./db")

app.use require './login'

# after here, the user must be login

app.use (req, res, next) ->
  if req.session.user.roles.indexOf("rf") isnt -1 and req.session.loginRf is true
    next()
  else
    res.sendStatus 401

app.use '/api', require './api'

app.listen 3232, () ->
  console.log "Serveur lancé sur le port 3232"
