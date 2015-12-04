express = require('express')
app     = express()
access  = require "../accessControl"
db      = require "../db"
utils   = require "../utils"
middles = require "../middles"

Promise  = require "bluebird"

app.route '/'
.get access.rf, (req, res) ->
  search = ""
  param = [(req.query.limit or 50),(req.query.skip or 0)]
  if req.query.search
    search = """
      WHERE lower(login) LIKE $3::text
      OR lower(nom) LIKE $3::text
      OR lower(prenom) LIKE $3::text
      OR lower(mail) LIKE $3::text
    """
    param.push "%#{req.query.search.toLowerCase()}%"

  db().then (connection) ->
    #  mdp_super, , mdp AS pass_hash
    connection.client.query """
      SELECT DISTINCT ardoise.id, login, utilisateur.nom AS nom, prenom, role_id, montant
      FROM "public"."ardoise"
      INNER JOIN utilisateur on "utilisateur".ardoise_id = ardoise.id
      LEFT JOIN utilisateur_role on utilisateur_role.utilisateur_id = utilisateur.id
      #{search}
      ORDER BY nom, prenom
      LIMIT $1::int
      OFFSET $2::int
    """, param
  .then (users) ->
    res.send(users.rows)
  .catch (err) ->
    console.error "err::consommables:", err
    res.status(500).send(err)
  .finally ->
    @connection.done()

app.route '/:login'
.get access.rf, (req, res) ->
  db().then (connection) ->
    #  mdp_super, , mdp AS pass_hash
    connection.client.query """
      SELECT DISTINCT ardoise.id, login, utilisateur.nom AS nom, prenom, role_id, montant, mail
      FROM "public"."ardoise"
      INNER JOIN utilisateur on "utilisateur".ardoise_id = ardoise.id
      LEFT JOIN utilisateur_role on utilisateur_role.utilisateur_id = utilisateur.id
      WHERE login = $1::text
    """, [req.params.login]
  .then (users) ->
    if users.rows.length < 1
      res.status(404).send()
    else
      res.send(users.rows[0])
  .catch (err) ->
    console.error "err::users:", err
    res.status(500).send(err)
  .finally ->
    @connection.done()

module.exports = app
