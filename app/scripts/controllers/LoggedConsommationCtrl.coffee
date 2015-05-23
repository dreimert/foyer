angular.module "ardoise.controllers"
.controller "LoggedConsommationCtrl", ($scope, UserService, $mdToast, consommations, TitleService) ->
  TitleService.setTitle("#{UserService.user.nom} #{UserService.user.prenom} : #{UserService.user.montant}")
  $scope.consommations = consommations
