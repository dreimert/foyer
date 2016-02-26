express = require('express')
app     = express()
access  = require "../accessControl"
db      = require "../db"
utils   = require "../utils"
middles = require "../middles"

Promise  = require "bluebird"

app.route '/'
.get access.rf, (req, res) ->
  utils.requestAndSend(
    req,
    res,
    """
      SELECT date, description, login
      FROM log
      LEFT JOIN utilisateur on utilisateur.id = log.utilisateur_id
      ORDER BY date DESC
      LIMIT $1::int
      OFFSET $2::int
    """,
    [(req.query.limit or 10), (req.query.skip or 0)],
    "GET historique"
  )

app.route '/count'
.get access.rf, utils.requestAndSendHandler(
  """
    SELECT count(*)
    FROM "public"."log"
  """,
  [],
  "GET historique/count",
  (rows) ->
    rows[0].count
)

module.exports = app
