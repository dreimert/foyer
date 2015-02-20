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
            $http.get "/api/user/#{$stateParams.login}"
            .success (data) ->
              resolve data
            .error (data) ->
              reject data
    )
    .state "logged.rf",
      abstract: true
      templateUrl: "logged.rf.jade"
      url: "/rf"
      resolve:
        rf: (UserService) ->
          UserService.hasRole('rf')
    .state("logged.rf.user",
      url: "/user"
      templateUrl: "logged.rf.user.jade"
      controller: "LoggedAccueilController"
    ).state("logged.rf.consommation",
      url: "/consommation"
      templateUrl: "logged.rf.consommation.jade"
      controller: "loggedRfConsommationController"
      resolve:
        consommations: ($http, $q) ->
          $q (resolve, reject) ->
            $http.get "/api/consommation"
            .success (data) ->
              resolve data
            .error (data) ->
              reject data
    )
.run ($state, UserService, $rootScope) ->
    $rootScope.$on '$stateChangeError', (event, toState, toParams, fromState, fromParams, error) ->
      console.log "stateChangeError", error
      if error.data is "Unauthorized"
        event.preventDefault()
        $state.go 'login'
