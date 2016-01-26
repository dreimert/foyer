db = require "./db"

errorHandler = (name, res, func) ->
  (err) ->
    console.error "#{name}::", err, err.stack
    res.status(500).send(err)
    if func?
      func.apply(@)

requestAndSend = (req, res, query, params, apiName, rewriteFunc = (data) -> data) ->
  db().then (connection) ->
    connection.client.query query, params
  .then (result) ->
    res.send(rewriteFunc(result.rows))
  .catch errorHandler(apiName, res)
  .finally ->
    @connection.done()

module.exports =
  errorHandler: errorHandler

  sendHandler: (res) ->
    (data) ->
      res.send data

  sendUserHandler: (req, res) ->
    res.send req.session.user

  requestAndSend: requestAndSend

  requestAndSendHandler: (query, params, apiName, rewriteFunc) ->
    (req, res) ->
      requestAndSend(req, res, query, params, apiName, rewriteFunc)

  order: (fields, textFields, order, defaultValue) ->
    desc = false
    unless order?
      field = defaultValue
    else if order[0] is "-"
      desc = true
      field = order[1..]
    else
      field = order

    unless field in fields
      field = defaultValue

    if field in textFields
      order = "lower(#{field})"
    else
      order = field

    if desc
      order = "#{order} DESC"
    order
