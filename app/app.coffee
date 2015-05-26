"use strict"

angular.module("ardoise", [
  "ui.router"
  'ngAnimate'
  'ngMaterial'
  "ardoise.filters"
  "ardoise.services"
  "ardoise.directives"
  "ardoise.controllers"
  "ardoise.templates"
]).config ($stateProvider, $urlRouterProvider) ->

    # For any unmatched url, redirect to /state1
    $urlRouterProvider.otherwise "/accueil"

    # Now set up the states
    $stateProvider.state "login",
      url: "/login/:lieu"
      templateUrl: "login.jade"
      controller: "LoginCtrl"
    .state "anonyme",
      abstract: true
      url: "/anonyme"
      templateUrl: "anonyme.jade"
    .state "anonyme.accueil",
      url: "/accueil"
      templateUrl: "logged.accueil.jade"
      controller: "AnonymeAccueilCtrl"
      resolve:
        consommables: ($stateParams, $http, $q) ->
          $q (resolve, reject) ->
            $http.get "/api/consommable"
            .success (data) ->
              resolve data
            .error (data) ->
              reject data
    .state "anonyme.paiement",
      url: "/paiement/:montant"
      templateUrl: "anonyme.paiement.jade"
      controller: "AnonymePaiementCtrl"
    .state "logged",
      abstract: true
      templateUrl: "logged.jade"
      controller: "LoggedCtrl"
      resolve:
        user: (UserService) ->
          UserService.getUser()
    .state "logged.accueil",
      url: "/accueil"
      templateUrl: "logged.accueil.jade"
      controller: "LoggedAccueilCtrl"
      resolve:
        consommables: ($stateParams, $http, $q) ->
          $q (resolve, reject) ->
            $http.get "/api/consommable"
            .success (data) ->
              resolve data
            .error (data) ->
              reject data
    .state "logged.deconnexion",
      url: "/deconnexion"
      templateUrl: "logged.deconnexion.jade"
      controller: "LoggedDeconnexionCtrl"
    .state "logged.consommation",
      url: "/consommation"
      templateUrl: "logged.consommation.jade"
      controller: "LoggedConsommationCtrl"
      resolve:
        consommations: ($stateParams, $http, $q) ->
          $q (resolve, reject) ->
            $http.get "/api/me/consommation"
            .success (data) ->
              resolve data
            .error (data) ->
              reject data
    .state "logged.auth",
      url: "/auth"
      templateUrl: "logged.auth.jade"
      controller: "LoggedAuthCtrl"
      resolve:
        rf: (UserService) ->
          UserService.hasRole('rf')
    .state "logged.rf",
      abstract: true
      templateUrl: "logged.rf.jade"
      url: "/rf"
      resolve:
        auth: (UserService) ->
          UserService.authRf()
    .state "logged.rf.accueil",
      url: "/accueil"
      templateUrl: "logged.rf.accueil.jade"
    .state "logged.rf.user",
      url: "/user"
      templateUrl: "logged.rf.user.jade"
      controller: "LoggedRfUserCtrl"
    .state "logged.rf.detail",
      url: "/user/:login"
      templateUrl: "logged.rf.user.detail.jade"
      controller: "LoggedRfUserDetailCtrl"
      resolve:
        user: ($stateParams, $http, $q) ->
          $q (resolve, reject) ->
            $http.get "/api/user/#{$stateParams.login}"
            .success (data) ->
              resolve data
            .error (data) ->
              reject data
    .state "logged.rf.consommation",
      url: "/consommation"
      templateUrl: "logged.rf.consommation.jade"
      controller: "loggedRfConsommationCtrl"
      resolve:
        consommations: ($http, $q) ->
          $q (resolve, reject) ->
            $http.get "/api/consommation"
            .success (data) ->
              resolve data
            .error (data) ->
              reject data
.run ($state, UserService, $rootScope) ->
    $rootScope.$on '$stateChangeError', (event, toState, toParams, fromState, fromParams, error) ->
      if error.data is "Unauthorized"
        event.preventDefault()
        $state.go 'login'
      else if error is "not auth like rf"
        event.preventDefault()
        $state.go 'logged.auth'
      else
        console.error "stateChangeError", error
