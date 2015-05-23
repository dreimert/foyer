angular.module "ardoise.controllers"
.controller "loggedRfConsommationCtrl", ($scope, TitleService, consommations) ->
  TitleService.setTitle("Dernière consommation")
  $scope.consommations = consommations
