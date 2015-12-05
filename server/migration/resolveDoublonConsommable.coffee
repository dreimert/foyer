db      = require "../db"
Promise  = require "bluebird"

db().then (connection) ->
  connection.client.query """
    SELECT "groupeV".id, lieu_id, groupe_id, date, nom, nomreduit
    FROM "groupeV"
    INNER JOIN groupe ON (groupe_id = groupe.id)
    WHERE actif
    ORDER BY groupe_id, date
  """
.then (consommables) ->
  last = consommables.rows[0]
  for consommable in consommables.rows[1..]
    if consommable.groupe_id is last.groupe_id and consommable.lieu_id is last.lieu_id
      console.log "unactive ", last
      @connection.client.query """
        UPDATE "groupeV" SET actif = false WHERE id = $1::int;
      """, [last.id]
      .catch (err) ->
        console.error "UPDATE ERROR", err
    last = consommable
.catch (err) ->
  console.error "err", err
.finally ->
  @connection.done()

#module.exports =
