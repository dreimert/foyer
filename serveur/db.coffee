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
  login: (login, mdp, callback) ->
    connect().then (connection) ->
      new Promise (resolve, reject) ->
        connection.client.query 'SELECT * FROM utilisateur WHERE login = $1 AND mdp = md5($2)', [login, mdp], (err, row) ->
          if err?
            connection.done()
            return reject status: 500, msg: err

          if row.rows[0]?
            resolve row.rows[0]
          else
            reject status: 401, msg: "not match"

          connection.done()

  search: (search, callback) ->
    connect().then (connection) ->
      connection.client.query "SELECT login as id, prenom, nom FROM utilisateur WHERE prenom ~* $1 OR nom ~* $1 ORDER BY nom, prenom", [search], (err, result) ->
        if (err)
          callback 500, err
          connection.done()
          return

        console.log "rows :", result.rows
        callback 200, result.rows
        connection.done()
    .catch (err) ->
      console.log "err::search:", err

  user: (login, callback) ->
    connect().then (connection) ->
      connection.client.query """
        SELECT * 
        FROM utilisateur
        WHERE login = $1
        """, [login], (err, row) ->
          console.error "user #{login} :", err, row
          if (err)
            callback 500, err
            connection.done()
            return

          if row.rows[0]?
            callback 200, row.rows[0]
          else
            callback 401, "not match"
          connection.done()
