"use strict"

angular.module("aae.services", [])
.value("version", "0.1"
).factory("TitleService", [
  () ->
    new class TitleService
      constructor: () ->
        @title = "Accueil"
      setTitle: (title) ->
        @title = title
      getTitle: () ->
        @title

]).factory("UserService", [
  "$http"
  ($http) ->
    new class UserService
      constructor: ->
        @name = false

      signIn: (name) ->
        @name    = name
        @entered = Date.now()

      signOut: ->
        # hard refresh of the page on logout to run constructor of all services
        window.location.reload()
        
      signedIn: ->
        @name
])
