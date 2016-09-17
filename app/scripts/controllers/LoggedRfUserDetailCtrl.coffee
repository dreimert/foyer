angular = require 'angular'

angular.module "ardoise.controllers"
.controller "LoggedRfUserDetailCtrl", ($scope, user) ->
  $scope.personne = user
