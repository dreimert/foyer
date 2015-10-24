express = require('express')
app     = express()
conf    = require('../conf')
access  = require "../serveur/accessControl"
Pgb     = require("pg-bluebird")
pgb     = new Pgb()

connection = () ->
  pgb.connect(conf.db.pg)

connection().then (connection) ->
  console.log "ok"
  connection.done()
.catch (err) ->
  console.error err

###
# Entrée :
#  - req.body.login
#  - req.body.password
# Si logué :
#   req.session.logged = true
#   req.session.user =
      id: id
      login: login
      nom: nom
      prenom: prenom
      roles: [roleName]
      montant: montantArdoise
# Renvoier :
#  - 404 : si mdp faut ou login inexistant
#  - 200 + req.session.user : si valide
###
app.post '/login', (req, res) ->
  login = req.body.login
  pwd = req.body.password

  console.log login, pwd

  connection().bind({}).then (connection) ->
    @connection = connection
    #  mdp_super, , mdp AS pass_hash
    connection.client.query """
      SELECT DISTINCT ardoise.id, login, utilisateur.nom AS nom, prenom, role_id, montant
      FROM "public"."ardoise"
      LEFT JOIN utilisateur on "utilisateur".ardoise_id = ardoise.id
      LEFT JOIN utilisateur_role on utilisateur_role.utilisateur_id = utilisateur.id
      WHERE login = $1::text AND mdp = MD5($2::text)
    """, [login, pwd]
  .then (user) ->
    if user.rowCount isnt 1
      res.status(404).send()
    else
      user = user.rows[0]
      req.session.logged = true
      req.session.user =
        id: user.id
        login: user.login
        nom: user.nom
        prenom: user.prenom
        roles: if role_id is 5 then ['rf'] else []
        montant: user.montant
      res.send req.session.user
    @connection.done()
  , (err) ->
    console.error "err::", err
    res.status(500).send(err)

app.get '/logged', access.logged, (req, res) ->
  res.send req.session.user

app.get '/logout', access.logged, (req, res) ->
  req.session.destroy()
  res.sendStatus(200)

###
app.post '/loginRf', access.logged, (req, res) ->
  User
  .findOne(_id: req.session.user.id)
  .exec()
  .then (user) ->
    if user is null
      res.status(404).send()
    else if user.authenticateWithRole("rf", req.body.password)
      req.session.loginRf = true
      res.send true
    else
      res.status(404).send()
  .then null, (err) ->
    res.status(500).send(err)
###
module.exports = app
