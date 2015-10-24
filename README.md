# Annuaire des anciens éléves de l'ENS de Lyon

Work in progress, it's not a functional version.

## Get It Working

* Installer node.js
* Installer bower, grunt et coffee-script

    npm install -g bower grunt-cli coffee-script

* Installer les dépendences

    npm install
    bower install

* Copier et configurer le système

    cp conf.default.coffee conf.coffee
    nano conf.coffee

* Copier la base postgres

* Lancer le serveur

    grunt
    
* Ouvrir un navigateur et aller sur : <http://localhost:3333/>

### Pour le serveur mongo

* lancer mongoDB

* Lance la migration de la base

    coffee migration

* Lancer l'application

    grunt mongoServe

* Ouvrir un navigateur et aller sur : <http://localhost:3333/>
