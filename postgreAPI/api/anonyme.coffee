express = require('express')
app     = express()
db      = require "../db"
utils   = require "../utils"
middles = require "../middles"

Promise  = require "bluebird"

app.route '/consommation'
.post(
  middles.setAnonyme,
  middles.checkAndParseConsommations,
  middles.registerConsommations,
  (req, res) ->
    res.send
      montant: req.montant
)

module.exports = app
