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
  "$http", "$q"
  ($http, $q) ->
    new class UserService
      constructor: ->
        @name = false
        $http.get '/logged'
        .success (data) =>
          @name = data.name

      signIn: (login, password) ->
        $q (resolve, reject) =>
          $http.post '/login', {login: login, password: password}
          .success (data) =>
            @name = data.name
            resolve @name
          .error (data) =>
            reject data

      signOut: ->
        # hard refresh of the page on logout to run constructor of all services
        $http.get '/logout'
        .success () ->
          window.location.reload()
        
      signedIn: ->
        @name
])
