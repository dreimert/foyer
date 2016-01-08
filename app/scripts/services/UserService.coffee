angular.module "ardoise.services"
.factory "UserService", ($http, $q, LieuService) ->
  new class UserService
    constructor: ->
      @init()

    init: ->
      @reset
      @promise = $http.get('logged').then (data) =>
        @setInterval()
        @user = data.data
        @name = data.data.prenom
        @user

    reset: ->
      @name = false
      @user = null
      @promise = $q.reject("not login")
      console.log "@interval", @interval
      if @interval
        clearInterval @interval
      @interval = null

    setInterval: ->
      @interval = setInterval =>
        $http.get('logged')
        .then null, (err) =>
          @goLogin()
      , 10000

    goLogin: ->
      window.location.replace("/#/login/#{LieuService.getLieu().value}")

    signIn: (login, password) ->
      @promise = $q (resolve, reject) =>
        $http.post 'login', {login: login, password: password}
        .then (data) =>
          @setInterval()
          @user = data.data
          @name = data.data.prenom
          resolve @user
        , (data) ->
          reject data

    authRf: () ->
      @promise
      .then (user) ->
        if user.loginRf
          Promise.resolve(true)
        else
          Promise.reject("not auth like rf")

    loginRf: (password) ->
      @promise = $q (resolve, reject) =>
        $http.post 'loginRf', {login: @user.login, password: password}
        .then (data) =>
          @user.loginRf = true
          resolve @user
        , (data) ->
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
      @reset()
      $http.get 'logout'
      .finally () =>
        @goLogin()
