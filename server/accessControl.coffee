module.exports =
  logged: (req, res, next) ->
    if req.session? and req.session.logged is true
      req.user = req.session.user
      next()
    else
      res.sendStatus 401

  rf: (req, res, next) ->
    if req.session? and req.session.user?.roles?.indexOf("rf") isnt -1 and req.session.user?.loginRf is true
      next()
    else
      res.sendStatus 401
