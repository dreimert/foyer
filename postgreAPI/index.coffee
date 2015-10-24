express = require('express')
app     = express()
conf    = require('../conf')
bodyParser = require('body-parser')
session    = require('express-session')

app.use express.static(__dirname + '/../build')
app.use session
  secret: conf.cookie.secretKey
  cookie:
    maxAge: conf.cookie.maxAge
app.use bodyParser.json()

app.use require './login'

#app.use '/api', require './api'

app.listen 3232, () ->
  console.log "Serveur lancé sur le port 3232"
