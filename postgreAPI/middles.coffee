lieux = ["foyer", "kfet"]

module.exports =
  requireLieu: (req, res, next) ->
    if lieux.indexOf(req.body.lieu) < 0
      res.status(400).send('no lieu param')
    else
      req.lieu = req.body.lieu
      next()
