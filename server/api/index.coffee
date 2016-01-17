express = require('express')
app     = express()
access  = require "../accessControl"
db      = require "../db"
utils   = require "../utils"

Promise  = require "bluebird"

app.use '/anonyme', require './anonyme'
app.use '/me', require './me'
app.use '/consommable', require './consommable'
app.use '/consommation', require './consommation'
app.use '/user', require './user'
app.use '/frigo', require './frigo'
app.use '/historique', require './historique'

module.exports = app
