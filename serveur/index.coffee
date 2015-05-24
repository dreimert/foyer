express = require('express')
app     = express()
conf    = require('../conf')

mongoose = require('mongoose')
console.log "mongo", conf.db.mongo
mongoose.connect conf.db.mongo, (err) ->
  if err
    throw err

Consommation = mongoose.model "Consommation", require "../models/ConsommationSchema"
User         = mongoose.model "User"        , require "../models/UserSchema"
Consommable  = mongoose.model "Consommable" , require "../models/ConsommableSchema"
Transfert    = mongoose.model "Transfert"   , require "../models/TransfertSchema"
Credit       = mongoose.model "Credit"      , require "../models/CreditSchema"

bodyParser = require('body-parser')
session    = require('express-session')

app.use express.static(__dirname + '/../build')

app.use session(secret: 'keyboard cat', cookie: maxAge: 3600000)
app.use bodyParser.json()

app.use require './login'

app.use '/api', require './api'

app.listen 3232, () ->
  console.log "Serveur lancé sur le port 3232"
