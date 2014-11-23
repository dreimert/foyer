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
    $urlRouterProvider.otherwise "/accueil"
    
    # Now set up the states
    $stateProvider.state("login",
      url: "/login"
      templateUrl: "login.html"
      controller: "LoginController"
    ).state("logged",
      abstract: true
      templateUrl: "logged.html"
      controller: "LoggedController"
      resolve:
        user: ["UserService", (UserService) ->
          UserService.getUser()
        ]
    ).state("logged.accueil",
      url: "/accueil"
      templateUrl: "logged.accueil.html"
      controller: "LoggedAccueilController"
    )
]).run([
  '$state', 'UserService', '$rootScope'
  ($state, UserService, $rootScope) ->
    $rootScope.$on '$stateChangeError', (event, toState, toParams, fromState, fromParams, error) ->
      if error.data is "Unauthorized"
        event.preventDefault()
        $state.go 'login'
    
])
