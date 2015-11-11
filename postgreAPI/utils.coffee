module.exports =
  errorHandler: (res) ->
    (err) ->
      res.status(500).send err

  sendHandler: (res) ->
    (data) ->
      res.send data
