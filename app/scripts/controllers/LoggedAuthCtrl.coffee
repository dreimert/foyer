angular = require 'angular'

angular.module "ardoise.controllers"
.controller "LoggedAuthCtrl", ($scope, $state, UserService, $mdToast) ->
  $scope.onFormSubmit = ->
    UserService.loginRf($scope.password)
    .then () ->
      $state.go "logged.rf.accueil"
    ,
      () ->
        $mdToast.show($mdToast.simple().content('mot de passe incorrect !'))
