db = require("./pg")
config = require "../conf"
mongoose = require "mongoose"
Promise = require("bluebird")

Consommation = mongoose.model "Consommation", require "../models/ConsommationSchema"
User         = mongoose.model "User"        , require "../models/UserSchema"
Consommable  = mongoose.model "Consommable" , require "../models/ConsommableSchema"
Transfert    = mongoose.model "Transfert"   , require "../models/TransfertSchema"
Credit       = mongoose.model "Credit"      , require "../models/CreditSchema"

convertArdoiseId = {}
convertArdoiseIdToLogin = {}
nb = 0
loginCp = 0

mongoose.connect(config.db.mongo)
mongoose.connection.once 'open', ->
  Promise.resolve()
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
    db.users (user) ->
      if user.role_id?
        user.roles = [{name: "rf", pass_hash: user.mdp_super}]
      unless user.nom
        console.log "#{user.login}::nom :", user.nom
        user.nom = "Unknow"
      unless user.prenom
        console.log "#{user.login}::prenom :", user.prenom
        user.prenom = "Unknow"
      unless user.login
        console.log "#{user.login}::login :", user.login
        user.login = "Unknow#{loginCp++}"
      unless user.mail
        console.log "#{user.login}::mail :", user.mail
        user.mail = "Unknow"
      unless user.pass_hash
        console.log "#{user.login}::pass_hash :", user.pass_hash
        user.pass_hash = "Unknow"
      User.create user
      .then (userM) ->
        convertArdoiseId[user.id] = userM._id
        nb++
      , (err) ->
        console.error user, err
  .then (result) ->
    console.log "Nb users :", result.rowCount
    console.log "convertArdoiseId:", nb
  .then () ->
    db.consommations (consommation) ->
      if convertArdoiseIdToLogin[consommation.ardoise]?
        consommation.user = convertArdoiseIdToLogin[consommation.ardoise]
      else
        consommation.user = null
      consommation.user = convertArdoiseId[consommation.ardoise]
      Consommation.create consommation
      .then null, (err) ->
        console.error err
  .then (result) ->
    console.log "Nb consommations :", result.rowCount
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
      credit.user  = convertArdoiseId[credit.ardoise]
      Credit.create credit
      .then null, (err) ->
        console.error credit, err
  .then (result) ->
    console.log "Nb credits :", result.rowCount
  .then () ->
    console.log "End!"
  .catch (err) ->
    console.error err, err.stack()
