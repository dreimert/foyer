module.exports =
  logged: (req, res, next) ->
    if req.session.logged is true
      next()
      req.user = req.session.user
    else
      res.sendStatus 401

  rf: (req, res, next) ->
    if req.session.user?.roles?.indexOf("rf") isnt -1 and req.session.user?.loginRf is true
      next()
    else
      res.sendStatus 401
