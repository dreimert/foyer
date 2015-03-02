db = require("./pg")
config = require "../conf"
mongoose = require "mongoose"
Promise = require("bluebird")

Ardoise      = mongoose.model "Ardoise"     , require "../models/ArdoiseSchema"
Consommation = mongoose.model "Consommation", require "../models/ConsommationSchema"
User         = mongoose.model "User"        , require "../models/UserSchema"
Consommable  = mongoose.model "Consommable" , require "../models/ConsommableSchema"
Transfert    = mongoose.model "Transfert"   , require "../models/TransfertSchema"
Credit       = mongoose.model "Credit"      , require "../models/CreditSchema"

convertArdoiseId = {}
convertUserId = {}
nb = 0

mongoose.connect(config.db.mongo)
mongoose.connection.once 'open', ->
  Promise.resolve()
  .then () ->
    Ardoise
    .remove({})
    .exec()
  .then () ->
    Consommation
    .remove({})
    .exec()
  .then () ->
    User
    .remove({})
    .exec()
  .then () ->
    Consommable
    .remove({})
    .exec()
  .then () ->
    Transfert
    .remove({})
    .exec()
  .then () ->
    Credit
    .remove({})
    .exec()
  .then () ->
    db.ardoises (ardoise) ->
      Ardoise.create
        montant: ardoise.montant
        lastNegatif: ardoise.dernierenegativite
        archive: ardoise.archive
      .then (ardoiseMongo) ->
        convertArdoiseId[ardoise.id] = ardoiseMongo._id
        nb++
        return
  .then (result) ->
    console.log "Nb ardoises :", result.rowCount
    console.log "convertArdoiseId:", nb
  .then () ->
    ###
    db.consommations (consommation) ->
      consommation.ardoise = convertArdoiseId[consommation.ardoise]
      Consommation.create consommation
      .then null, (err) ->
        console.error err
    ###
    rowCount: 0
  .then (result) ->
    console.log "Nb consommations :", result.rowCount
  .then () ->
    db.users (user) ->
      if user.role_id?
        user.roles = [{name: "rf", pass_hash: user.mdp_super}]
      unless user.nom
        console.log "#{user.login}::nom :", user.nom
        user.nom = "Unknow"
      unless user.prenom
        console.log "#{user.login}::prenom :", user.prenom
        user.prenom = "Unknow"
      user.ardoise = convertArdoiseId[user.ardoise]
      User.create user
      .then (userM) ->
        convertUserId[user.id] = userM._id
      , (err) ->
        console.error user, err
  .then (result) ->
    console.log "Nb users :", result.rowCount
  .then () ->
    db.consommables (consommable) ->
      if consommable.commentaire is "None"
        consommable.commentaire = undefined
      Consommable.create consommable
      .then null, (err) ->
        console.error consommable, err
  .then (result) ->
    console.log "Nb consommables :", result.rowCount
  .then () ->
    db.transferts (transfert) ->
      transfert.debiteur  = convertArdoiseId[transfert.debiteur]
      transfert.crediteur = convertArdoiseId[transfert.crediteur]
      Transfert.create transfert
      .then null, (err) ->
        console.error transfert, err
  .then (result) ->
    console.log "Nb transferts :", result.rowCount
  .then () ->
    db.credits (credit) ->
      credit.ardoise  = convertArdoiseId[credit.ardoise]
      Credit.create credit
      .then null, (err) ->
        console.error credit, err
  .then (result) ->
    console.log "Nb credits :", result.rowCount
  .then () ->
    console.log "End!"
  .catch (err) ->
    console.error err, err.stack()
