angular.module "ardoise.controllers"
.controller "loggedRfConsommationCtrl", ($scope, consommations) ->
  $scope.consommations = consommations
