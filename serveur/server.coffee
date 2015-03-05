express = require('express')
app     = express()
conf = require('../conf')

mongoose = require('mongoose')
mongoose.connect(conf.db.mongo)

Consommation = mongoose.model "Consommation", require "../models/ConsommationSchema"
User         = mongoose.model "User"        , require "../models/UserSchema"
Consommable  = mongoose.model "Consommable" , require "../models/ConsommableSchema"
Transfert    = mongoose.model "Transfert"   , require "../models/TransfertSchema"
Credit       = mongoose.model "Credit"      , require "../models/CreditSchema"

bodyParser = require('body-parser')
session = require('express-session')

app.use express.static(__dirname + '/../build')

app.use session(secret: 'keyboard cat', cookie: maxAge: 3600000)
app.use bodyParser.json()

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
