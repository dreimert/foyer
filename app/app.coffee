"use strict"

angular.module("aae", [
  "ui.router"
  'ngAnimate'
  'ngMaterial'
  "aae.filters"
  "aae.services"
  "aae.directives"
  "aae.controllers"
]).config([
  "$stateProvider"
  "$urlRouterProvider"
  ($stateProvider, $urlRouterProvider) ->

    # For any unmatched url, redirect to /state1
    $urlRouterProvider.otherwise "/login"
    
    # Now set up the states
    $stateProvider.state("login",
      url: "/login"
      templateUrl: "login.html"
      controller: "LoginController"
    ).state("logged",
      abstract: true
      url: "/"
      templateUrl: "logged.html"
      controller: "LoggedController"
    ).state("logged.accueil",
      url: "/accueil"
      templateUrl: "logged.accueil.html"
      controller: "LoggedAccueilController"
    )
]).run([
  '$state', 'UserService', '$rootScope'
  ($state, UserService, $rootScope) ->
    $rootScope.$on '$stateChangeStart', (e, toState, toParams, fromState, fromParams) ->
      # if user is not logged in and wants to access pages other than login,
      # than force a redirect to the login page
      unless UserService.signedIn()
        console.log "not Signed In"
        unless toState.name is 'login'
          console.log "reroute"
          e.preventDefault()
          $state.go 'login'
])
