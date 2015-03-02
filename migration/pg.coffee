pg = require('pg')
Promise = require("bluebird")
conf = require('../conf')

connect = () ->
  new Promise (resolve, reject) ->
    pg.connect conf.db.pg, (err, client, done) ->
      if err?
        return reject err
      else
        resolve client:client, done:done

connect().then (connect) ->
  console.log "ok"
  connect.done()
.catch (err) ->
  console.error err

transformTable = (sql) ->
  (transform) ->
    connect().then (connection) ->
      new Promise (resolve, reject) ->
        query = connection.client.query sql
        query.on 'row', (row) ->
          transform row
          
        query.on 'end', (result) ->
          connection.done()
          resolve result

        query.on 'error', (err) ->
          connection.done()
          reject err

module.exports =
  ###
  # params:
  #   - connection
  #   - login
  #   - mdp
  #   - callback : (err, userInfo) ->
  ###
  ardoises: transformTable 'SELECT * FROM ardoise'

  consommations: transformTable """
    SELECT nom AS consommable, uniteachetee AS quantity, prix_adh * uniteachetee AS montant, 'foyer' AS lieu, ardoise_id AS ardoise, "public"."consommation".date AS date
    FROM "public"."consommation"
    INNER JOIN "public"."groupeV" on "public"."consommation"."groupeV_id" = "public"."groupeV"."id"
    INNER JOIN "public"."groupe"   on "public"."groupeV"."groupe_id" = "public"."groupe"."id"
    WHERE uniteachetee != 0
  """

  users: transformTable """
    SELECT DISTINCT utilisateur.id, login, mdp AS pass_hash, utilisateur.nom AS nom, prenom, ardoise_id AS ardoise, promo, mail, mailvalide AS trustMail, departement.nom AS departement, date_dernier_envoi_mail AS lastMail, role_id, mdp_super
    FROM utilisateur
    LEFT JOIN departement on departement_id = departement.id
    LEFT JOIN utilisateur_role on utilisateur_role.utilisateur_id = utilisateur.id
  """

  consommables: transformTable """
    SELECT DISTINCT nom,
      (SELECT prix_adh FROM "public"."groupeV" WHERE "public"."groupeV"."groupe_id" = "public"."groupe"."id" ORDER BY "public"."groupeV".date DESC LIMIT 1) AS prix,
      commentaire, qte_frigo AS frigo
    FROM "public"."groupe"
    INNER JOIN stockgroupe on stockgroupe.groupe_id = "public"."groupe".id
  """
  transferts : transformTable """
    SELECT ardoise_id_debiteur AS debiteur, ardoise_id_crediteur AS crediteur, montant, date
    FROM transfert
  """
  
  credits : transformTable """
    SELECT ardoise_id AS ardoise, credit AS montant, date, nom AS mode
    FROM credit
    INNER JOIN moyenpaiement on moyenpaiement.id = moyenpaiement_id
  """
