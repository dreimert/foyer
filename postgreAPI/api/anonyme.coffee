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

###
  Promise.map req.consommations, (consommation) ->
    Consommation
    .create
      consommable: consommation.consommable
      quantity: consommation.quantity
      montant: consommation.montant
      lieu: req.lieu
      user: anonyme.id
  .then (consommations) ->
    montant = consommations.reduce (sum, consommation) ->
      sum += consommation.montant
    , 0

    User
    .findByIdAndUpdate anonyme.id, $inc: montant: montant
    .exec()
    .then (user) ->
      consommations
  .then (consommations) ->
    Promise
    .map consommations, (consommation) ->
      Consommable
      .update {nom: consommation.consommable},
        $inc:
          frigo: -consommation.quantity
      .exec()
  .then () ->
    "ok"
  .then utils.sendHandler(res), utils.errorHandler(res)
###


module.exports = app
