angular = require 'angular'

require 'angular-ui-router'

angular.module("ardoise", [
  "ui.router"
  require 'angular-animate'
  require 'angular-material-data-table'
  require 'angular-material'
  require 'angular-aria' # check if use
  require 'angular-messages' # check if use
  require 'angular-sanitize' # check if use
  require 'angular-moment'
  require './scripts/services'
  require './scripts/directives'
  require './scripts/controllers'
  require '../build/js/templates_browserify.js'
]).config (
  $stateProvider,
  $urlRouterProvider,
  $locationProvider,
  $mdThemingProvider
) ->

  $mdThemingProvider.theme('kfet')
  .primaryPalette('orange')
  .accentPalette('light-green')

  $mdThemingProvider.theme('foyer')
  .primaryPalette('light-green')
  .accentPalette('deep-orange')

  $mdThemingProvider.alwaysWatchTheme(true)

  $locationProvider.html5Mode requireBase:true
    # For any unmatched url, redirect to /state1
  $urlRouterProvider.otherwise "/foyer/accueil"

  # Now set up the states
  $stateProvider.state "login",
    url: "/login/:lieu"
    templateUrl: "login.jade"
    controller: "LoginCtrl"
  .state "anonyme",
    abstract: true
    url: "/anonyme/:lieu"
    templateUrl: "anonyme.jade"
    controller: "AnonymeCtrl"
    resolve:
      lieu: ($stateParams, LieuService) ->
        LieuService.resolve($stateParams.lieu)
  .state "anonyme.accueil",
    url: "/accueil"
    templateUrl: "logged.accueil.jade"
    controller: "AnonymeAccueilCtrl"
    resolve:
      consommables: ($stateParams, $http, $q, lieu) ->
        $q (resolve, reject) ->
          $http.get "api/consommable/#{lieu.value}"
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
    url: "/:lieu"
    templateUrl: "logged.jade"
    controller: "LoggedCtrl"
    resolve:
      user: (UserService) ->
        UserService.getUser()
      lieu: ($stateParams, LieuService) ->
        LieuService.resolve($stateParams.lieu)
  .state "logged.accueil",
    url: "/accueil"
    templateUrl: "logged.accueil.jade"
    controller: "LoggedAccueilCtrl"
    resolve:
      consommables: ($http, $q, lieu) ->
        $q (resolve, reject) ->
          $http.get "api/consommable/#{lieu.value}"
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
      consommations: ($http, $q) ->
        $q (resolve, reject) ->
          $http.get "api/me/consommation"
          .success (data) ->
            resolve data
          .error (data) ->
            reject data
      total: ($http, $q) ->
        $q (resolve, reject) ->
          $http.get "api/me/consommation/count"
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
        UserService.hasRole()
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
    controller: "LoggedRfAccueilCtrl"
  .state "logged.rf.user",
    url: "/user"
    templateUrl: "logged.rf.user.jade"
    controller: "LoggedRfUserCtrl"
  .state "logged.rf.userDetail",
    url: "/user/:login"
    templateUrl: "logged.rf.user.detail.jade"
    controller: "LoggedRfUserDetailCtrl"
    resolve:
      user: ($stateParams, $http, $q) ->
        $q (resolve, reject) ->
          $http.get "api/user/#{$stateParams.login}"
          .success (data) ->
            resolve data
          .error (data) ->
            reject data
  .state "logged.rf.createUser",
    url: "/create/user"
    templateUrl: "logged.rf.createUser.jade"
    controller: "LoggedRfCreateUserCtrl"
  .state "logged.rf.consommation",
    url: "/consommation"
    templateUrl: "logged.rf.consommation.jade"
    controller: "loggedRfConsommationCtrl"
    resolve:
      consommations: ($http, $q, lieu) ->
        $q (resolve, reject) ->
          $http.get "api/consommation/#{lieu.value}"
          .success (data) ->
            resolve data
          .error (data) ->
            reject data
      total: ($http, $q, lieu) ->
        $q (resolve, reject) ->
          $http.get "api/consommation/count/#{lieu.value}"
          .success (data) ->
            resolve data
          .error (data) ->
            reject data
  .state "logged.rf.frigo",
    url: "/frigo"
    templateUrl: "logged.rf.frigo.jade"
    controller: "loggedRfFrigoCtrl"
    resolve:
      consommations: ($http, $q, lieu) ->
        $q (resolve, reject) ->
          $http.get "api/frigo/#{lieu.value}"
          .success (data) ->
            resolve data
          .error (data) ->
            reject data
      total: ($http, $q, lieu) ->
        $q (resolve, reject) ->
          $http.get "api/frigo/count/#{lieu.value}"
          .success (data) ->
            resolve data
          .error (data) ->
            reject data
  .state "logged.rf.bar",
    url: "/bar"
    templateUrl: "logged.rf.bar.jade"
    controller: "LoggedRfBarCtrl"
    resolve:
      consommables: ($stateParams, $http, $q, lieu) ->
        $q (resolve, reject) ->
          $http.get "api/consommable/#{lieu.value}"
          .success (data) ->
            resolve data
          .error (data) ->
            reject data
  .state "logged.rf.historique",
    url: "/historique"
    templateUrl: "logged.rf.historique.jade"
    controller: "LoggedRfHistoriqueCtrl"
    resolve:
      historique: ($stateParams, $http, $q) ->
        $q (resolve, reject) ->
          $http.get "api/historique"
          .success (data) ->
            resolve data
          .error (data) ->
            reject data
      total: ($http, $q, lieu) ->
        $q (resolve, reject) ->
          $http.get "api/historique/count"
          .success (data) ->
            resolve data
          .error (data) ->
            reject data

  .state "logged.rf.log",
    url: "/log"
    templateUrl: "logged.rf.log.jade"
    controller: "loggedRfLogCtrl"
    resolve:
      logs: ($http, $q) ->
        $q (resolve, reject) ->
          $http.get "api/log"
          .success (data) ->
            resolve data
          .error (data) ->
            reject data
      total: ($http, $q) ->
        $q (resolve, reject) ->
          $http.get "api/log/count"
          .success (data) ->
            resolve data
          .error (data) ->
            reject data
.run ($state, UserService, $rootScope) ->
  $rootScope.$on '$stateChangeError',
    (event, toState, toParams, fromState, fromParams, error) ->
      if error.data is "Unauthorized"
        event.preventDefault()
        $state.go 'login'
      else if error is "not auth like rf"
        event.preventDefault()
        $state.go 'logged.auth'
      else
        console.error "stateChangeError", error
