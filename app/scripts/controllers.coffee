"use strict"

angular.module("aae.controllers", [
  "ui.router"
  "angularMoment"
]).controller("BodyController", [
  "$scope", "$state"
  ($scope, $state) ->
  
]).controller("LoginController", [
  "$scope", "$state", "UserService", "$mdToast"
  ($scope, $state, UserService, $mdToast) ->
    $scope.name = UserService.name or ""
    $scope.onFormSubmit = ->
      UserService.signIn($scope.login, $scope.password)
      .then () ->
        $state.go "logged.accueil"
      ,
        () ->
          $mdToast.show($mdToast.simple().content('Login ou mot de passe incorrect !'))

]).controller("LoggedController", [
  "$scope", "$state", "$window" , "UserService", "$mdSidenav", "TitleService"
  ($scope, $state, $window, UserService, $mdSidenav, TitleService) ->
    $scope.userService = UserService

    $scope.getTitle = () ->
      TitleService.getTitle()

    $scope.toggleSideNav = () ->
      $mdSidenav('left').toggle()

    $scope.signOut = ->
      $scope.userService.signOut()
    
]).controller("LoggedAccueilController", [
  "$scope"
  ($scope) ->
    $scope.$watch 'search', (value) ->
      if not value? or value.length is 0
        $scope.results = []
      else
        $scope.results = (nom: "Dubois", prenom: "Damien", others: "blabla" for i in [1..10])
]).controller("LoggedUserController", [
  () ->
])
