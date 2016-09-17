angular = require 'angular'

angular.module "ardoise.controllers"
.controller "LoginCtrl", ($scope, $state, $mdToast, UserService, LieuService) ->
  $scope.lieux = LieuService.getLieux()
  $scope.lieu = LieuService.setLieu($state.params.lieu).value

  $scope.$watch "lieu", (value) ->
    LieuService.setLieu value

  $scope.onFormSubmit = ->
    UserService.signIn($scope.login, $scope.password)
    .then () ->
      $state.go "logged.accueil", lieu: $scope.lieu
    ,
      () ->
        $mdToast.show(
          $mdToast.simple().content('Login ou mot de passe incorrect !')
        )
