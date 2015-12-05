express = require('express')
app     = express()
access  = require "../accessControl"
db      = require "../db"
utils   = require '../utils'

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

  db().then (connection) ->
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
        roles: if user.role_id is 5 then ['rf'] else []
        montant: user.montant
      res.send req.session.user
  .catch (err) ->
    console.error "err::", err
    res.status(500).send(err)
  .finally ->
    @connection.done()

app.get '/logged', access.logged, utils.sendUserHandler

app.get '/logout', access.logged, (req, res) ->
  req.session.destroy()
  res.sendStatus(200)

app.post '/loginRf', access.logged, (req, res) ->
  db().then (connection) ->
    #  mdp_super, , mdp AS pass_hash
    connection.client.query """
      SELECT DISTINCT *
      FROM utilisateur
      WHERE login = $1::text AND mdp_super = MD5($2::text)
    """, [req.session.user.login, req.body.password]
  .then (user) ->
    if user.rowCount isnt 1
      res.status(404).send()
    else
      req.session.user.loginRf = true
      res.send true
  .catch (err) ->
    console.error "err::", err
    res.status(500).send(err)
  .finally ->
    @connection.done()

module.exports = app
