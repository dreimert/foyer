mysql   = require('mysql')

connection = mysql.createConnection
  host     : 'localhost'
  user     : 'user'
  database : 'database'

connection.connect()

module.exports =
  ###
  # params:
  #   - login
  #   - mdp
  #   - callback : (status, userInfo) ->
  ###
  login: (login, mdp, callback) ->
    connection.query 'SELECT * FROM user WHERE login = ? AND mdp = ?', [login, mdp], (err, row) ->
      if (err)
        callback 500, err
        return

      if row[0]?
        callback 200,
          id: row[0].personne_id
          prenom: row[0].personne_prenom
          nom: row[0].personne_nomNaiss
      else
        callback 401, "not authorized"

  search: (search, callback) ->
    console.log "search :: ", search
    connection.query "SELECT * FROM personne WHERE personne_prenom LIKE ? OR personne_nomNaiss LIKE ? OR personne_nomUsuel LIKE ? OR personne_nomEpoux LIKE ? ORDER BY personne_nomNaiss, personne_prenom", ["#{search}%","#{search}%","#{search}%","#{search}%"], (err, result) ->
      if (err)
        callback 500, err
        return

      callback 200, result.map (row) ->
        id: row.personne_id
        prenom: row.personne_prenom
        nom: row.personne_nomNaiss
