express = require('express')
app     = express()
server  = require('http').Server(app)

app.use(express.static(__dirname + '/build'))

server.listen 3333, () ->
  console.log "Serveur lancé sur le port 3333"
