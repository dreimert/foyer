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

    setLieu: (newLieu) ->
      for lieu in @lieux when lieu.value is newLieu.toLowerCase()
        @lieu = lieu
      @lieu

    getLieu: ->
      @lieu

    getLieux: ->
      @lieux
