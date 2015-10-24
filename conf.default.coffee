module.exports =
  jade:
    site:
      title: "Ardoise alternative"
      descriptiont: "Site alternatif pour les ardoises"
      author: "Damien Reimert"
  db:
    pg: "postgres://localhost/dbname"
    mongo: "mongodb://127.0.0.1/ardoise"
  cookie:
    maxAge: 300000
    secretKey: "keyboardCat"
