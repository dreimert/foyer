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
        @user = null
        @promise = $http.get('/logged').success (data) =>
          @user = data
          @name = data.prenom
          @name

      signIn: (login, password) ->
        @promise = $q (resolve, reject) =>
          $http.post '/login', {login: login, password: password}
          .success (data) =>
            @user = data
            @name = data.prenom
            resolve @name
          .error (data) =>
            reject data

      getUser: () ->
        @promise

      signOut: ->
        # hard refresh of the page on logout to run constructor of all services
        $http.get '/logout'
        .success () ->
          window.location.reload()
])
