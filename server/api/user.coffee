express = require('express')
app     = express()
access  = require "../accessControl"
db      = require "../db"
utils   = require "../utils"
middles = require "../middles"

Promise  = require "bluebird"

app.route '/'
.get access.rf, (req, res) ->
  search = -> ""
  param = []
  if req.query.search
    search = (index) ->
      """
      WHERE lower(login) LIKE $#{index}::text
      OR lower(nom) LIKE $#{index}::text
      OR lower(prenom) LIKE $#{index}::text
      OR lower(mail) LIKE $#{index}::text
      """
    param.push "%#{req.query.search.toLowerCase()}%"

  db().then (connection) ->
    #  mdp_super, , mdp AS pass_hash
    Promise.all [
      connection.client.query """
        SELECT ardoise.id, login, utilisateur.nom AS nom, prenom, montant
        FROM utilisateur
        INNER JOIN "public"."ardoise" on "utilisateur".ardoise_id = ardoise.id
        #{search(3)}
        ORDER BY login
        LIMIT $1::int
        OFFSET $2::int
      """, [(req.query.limit or 50),(req.query.skip or 0)].concat param
    ,
      connection.client.query """
        SELECT count(*)
        FROM utilisateur
        #{search(1)}
      """, param
    ]
  .then ([users, count]) ->
    res.send(count: count.rows[0].count, users : users.rows)
  .catch (err) ->
    console.error "err::users:", err, err.stack
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
