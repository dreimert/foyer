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
      UserService.signIn($scope.name)
      $state.go "logged.accueil"

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
  () ->
])
