pg = require('pg')
Promise = require("bluebird")
conf = require('../conf')

connect = () ->
  new Promise (resolve, reject) ->
    pg.connect conf.db, (err, client, done) ->
      if err?
        return reject err
      else
        resolve client:client, done:done

connect().then (connect) ->
  console.log "ok"
  connect.done()
.catch (err) ->
  console.error err

module.exports =
  ###
  # params:
  #   - connection
  #   - login
  #   - mdp
  #   - callback : (err, userInfo) ->
  ###
  login: (login, mdp) ->
    connect().then (connection) ->
      new Promise (resolve, reject) ->
        connection.client.query 'SELECT id, login, mail, nom, prenom FROM utilisateur WHERE login = $1 AND mdp = md5($2)', [login, mdp], (err, row) ->
          connection.done()
          if err?
            return reject status: 500, msg: err

          if row.rows[0]?
            resolve row.rows[0]
          else
            reject status: 401, msg: "not match"


  getRoles: (utilisateurId) ->
    connect().then (connection) ->
      new Promise (resolve, reject) ->
        connection.client.query 'SELECT nom FROM utilisateur_role inner join role on role_id = role.id WHERE utilisateur_id = $1', [utilisateurId], (err, row) ->
          connection.done()
          if err?
            return reject status: 500, msg: err

          resolve row.rows.map (role) -> role.nom

  search: (search, callback) ->
    connect().then (connection) ->
      connection.client.query "SELECT login, id, prenom, nom FROM utilisateur WHERE prenom ~* $1 OR nom ~* $1 ORDER BY nom, prenom", [search], (err, result) ->
        connection.done()
        if (err)
          callback 500, err
          return

        callback 200, result.rows

  user: (login, callback) ->
    connect().then (connection) ->
      connection.client.query """
        SELECT id, nom, prenom, mail, login
        FROM utilisateur
        WHERE login = $1
        """, [login], (err, row) ->
          connection.done()
          if (err)
            callback 500, err
            return

          if row.rows[0]?
            callback 200, row.rows[0]
          else
            callback 401, "not match"
