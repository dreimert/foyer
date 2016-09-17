angular = require 'angular'

angular.module "ardoise.controllers"
.controller "AnonymeCtrl", ($scope, LieuService) ->
  $scope.lieu = LieuService.getLieu().value
