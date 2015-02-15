"use strict"

angular.module("aae.services", [])
.value("version", "0.1"
).factory("TitleService", [
  () ->
    new class TitleService
      constructor: () ->
        @title = "Accueil"
      setTitle: (title, backButton = false) ->
        @title = title
        @backButton = backButton
      showBackButton: () ->
        @backButton
      getTitle: () ->
        @title

]).factory("UserService", [
  "$http", "$q"
  ($http, $q) ->
    new class UserService
      constructor: ->
        @name = false
        @user = null
        @promise = $http.get('/logged').then (data) =>
          @user = data.data
          @name = data.data.prenom
          @user

      signIn: (login, password) ->
        @promise = $q (resolve, reject) =>
          $http.post '/login', {login: login, password: password}
          .then (data) =>
            @user = data.data
            @name = data.data.prenom
            resolve @user
          , (data) =>
            reject data

      getUser: () ->
        @promise

      hasRole: (role) ->
        new Promise (resolve, reject) =>
          @promise.then (user) ->
            console.log "user : ", user
            if user.roles.indexOf(role) isnt -1
              resolve true
            else
              reject "not role"
          , reject
          

      signOut: ->
        # hard refresh of the page on logout to run constructor of all services
        $http.get '/logout'
        .success () ->
          window.location.reload()
])
