angular = require 'angular'

angular.module "ardoise.services"
.factory "LieuService", ($http, $q) ->
  new class LieuService
    constructor: ->
      @lieux = [
        name: "Foyer"
        value: "foyer"
      ,
        name: "Kfet"
        value: "kfet"
      ]
      @lieu = @lieux[0]

    resolve: (lieu) ->
      $q (resolve, reject) =>
        if lieu in ["foyer", "kfet"]
          resolve @setLieu lieu
        else
          reject("lieu not found")

    setLieu: (newLieu) ->
      for lieu in @lieux when lieu.value is newLieu
        @lieu = lieu
      @lieu

    getLieu: ->
      @lieu

    getLieux: ->
      @lieux
