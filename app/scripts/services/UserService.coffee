angular.module "ardoise.services"
.factory "UserService", ($http, $q, LieuService) ->
  new class UserService
    constructor: ->
      @init()

    init: ->
      @name = false
      @user = null
      @authedRf = false
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

    authRf: () ->
      if @authedRf
        Promise.resolve(true)
      else
        Promise.reject("not auth like rf")

    loginRf: (password) ->
      @promise = $q (resolve, reject) =>
        $http.post '/loginRf', {login: @user.login, password: password}
        .then (data) =>
          @authedRf = true
          resolve true
        , (data) =>
          reject data

    getUser: () ->
      @promise

    hasRole: (role) ->
      new Promise (resolve, reject) =>
        @promise.then (user) ->
          if user.roles.indexOf(role) isnt -1
            resolve true
          else
            reject "not role #{role}"
        , reject

    signOut: ->
      # hard refresh of the page on logout to run constructor of all services
      $http.get '/logout'
      .success () =>
        #@init()
        window.location.replace("/#/login/#{LieuService.getLieu().value}")
