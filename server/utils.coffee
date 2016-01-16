module.exports =
  errorHandler: (name, res, func) ->
    (err) ->
      console.error "#{name}::", err, err.stack
      res.status(500).send(err)
      if func?
        func.apply(@)

  sendHandler: (res) ->
    (data) ->
      res.send data

  sendUserHandler: (req, res) ->
    res.send req.session.user

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
