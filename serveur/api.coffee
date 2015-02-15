express = require('express')
app     = express()

db = require("./db")

app.get '/search', (req, res) ->
  db.search req.query.search, (status, data) ->
    res.send(status, data)

app.get '/user', (req, res) ->
  db.user req.query.login, (status, data) ->
    res.send(status, data)

module.exports = app
