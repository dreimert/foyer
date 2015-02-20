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

  userSearch: (search, callback) ->
    connect().then (connection) ->
      new Promise (resolve, reject) ->
        connection.client.query "SELECT login, id, prenom, nom FROM utilisateur WHERE prenom ~* $1 OR nom ~* $1 OR login ~* $1 ORDER BY nom, prenom", [search], (err, result) ->
          connection.done()
          if (err)
            return reject status: 500, msg: err

          resolve result.rows

  userAll: (skip = 0) ->
    connect().then (connection) ->
      new Promise (resolve, reject) ->
        connection.client.query "SELECT login, id, prenom, nom FROM utilisateur ORDER BY nom, prenom LIMIT 50 OFFSET $1", [skip], (err, result) ->
          connection.done()
          if (err)
            reject status: 500, msg: err
            return

          resolve result.rows

  consommation: (skip = 0) ->
    connect().then (connection) ->
      new Promise (resolve, reject) ->
        connection.client.query """
        SELECT consommation.date, uniteachetee, "public"."groupe".nom, login
        FROM consommation
        INNER JOIN "public"."groupeV" ON "public"."groupeV".id = "public"."consommation"."groupeV_id"
        INNER JOIN "public"."groupe" ON "public"."groupeV".groupe_id = "public"."groupe"."id"
        LEFT JOIN utilisateur ON consommation.ardoise_id = utilisateur.ardoise_id
        ORDER BY consommation.date DESC
        LIMIT 50 OFFSET $1
        """, [skip], (err, result) ->
          connection.done()
          if (err)
            reject status: 500, msg: err
            return

          resolve result.rows

  user: (login) ->
    connect().then (connection) ->
      new Promise (resolve, reject) ->
        connection.client.query """
          SELECT id, nom, prenom, mail, login
          FROM utilisateur
          WHERE login = $1
          """, [login], (err, row) ->
            connection.done()
            if (err)
              return reject status: 500, msg: err

            if row.rows[0]?
              resolve row.rows[0]
            else
              reject status: 401, msg: "not match"
