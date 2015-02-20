express = require('express')
app     = express()

db = require("./db")

errorHandler = (res) ->
  (rep) ->
    res.status(rep.status).send rep.msg

sendRep = (res) ->
  (data) ->
    res.send data

app.route '/user'
.get (req, res) ->
  if req.query.search?
    db.userSearch(req.query.search).then sendRep(res), errorHandler(res)
  else
    db.userAll(req.query.skip or 0).then sendRep(res), errorHandler(res)
 
app.route '/user/:login'
.get (req, res) ->
  db.user(req.params.login).then sendRep(res), errorHandler(res)

app.route '/consommation'
.get (req, res) ->
  db.consommation(req.query.skip or 0).then sendRep(res), errorHandler(res)

module.exports = app
