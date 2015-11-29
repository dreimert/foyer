module.exports =
  errorHandler: (name, res, func) ->
    (err) ->
      console.error "#{name}::", err
      res.status(500).send(err)
      if func?
        func.apply(@)

  sendHandler: (res) ->
    (data) ->
      res.send data

  sendUserHandler: (req, res) ->
    res.send req.session.user
