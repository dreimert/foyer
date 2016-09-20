express = require('express')
app     = express()
appNew  = express()
conf    = require('../conf')
bodyParser = require('body-parser')
session    = require('express-session')

app.use express.static(__dirname + '/../build')
app.use session
  secret: conf.cookie.secretKey
  cookie:
    maxAge: conf.cookie.maxAge
  rolling: true
  resave: true
  saveUninitialized: false
app.use bodyParser.json()

app.use require './api/login'

app.use '/api', require './api'

appNew.use '/new', app

appNew.listen 3232, () ->
  console.info "Serveur lancé sur le port 3232"
