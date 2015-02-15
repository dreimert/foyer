"use strict"

angular.module("aae", [
  "ui.router"
  'ngAnimate'
  'ngMaterial'
  "aae.filters"
  "aae.services"
  "aae.directives"
  "aae.controllers"
  "ardoise.templates"
]).config ($stateProvider, $urlRouterProvider) ->

    # For any unmatched url, redirect to /state1
    $urlRouterProvider.otherwise "/accueil"
    
    # Now set up the states
    $stateProvider.state("login",
      url: "/login"
      templateUrl: "login.jade"
      controller: "LoginController"
    ).state("logged",
      abstract: true
      templateUrl: "logged.jade"
      controller: "LoggedController"
      resolve:
        user: (UserService) ->
          UserService.getUser()
    ).state("logged.accueil",
      url: "/accueil"
      templateUrl: "logged.accueil.jade"
    ).state("logged.user",
      url: "/user/:login"
      templateUrl: "logged.user.jade"
      controller: "LoggedUserController"
      resolve:
        user: ($stateParams, $http, $q) ->
          $q (resolve, reject) ->
            $http.get '/api/user', params: login: $stateParams.login
            .success (data) ->
              resolve data
            .error (data) ->
              reject data
    )
    .state("logged.rf",
      url: "/rf"
      templateUrl: "logged.rf.jade"
      controller: "LoggedAccueilController"
      resolve:
        rf: (UserService) ->
          UserService.hasRole('rf')
    )
.run ($state, UserService, $rootScope) ->
    $rootScope.$on '$stateChangeError', (event, toState, toParams, fromState, fromParams, error) ->
      console.log "stateChangeError", error
      if error.data is "Unauthorized"
        event.preventDefault()
        $state.go 'login'
