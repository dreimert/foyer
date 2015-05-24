angular.module "ardoise.controllers"
.controller "LoggedConsommationCtrl", ($scope, UserService, $mdToast, consommations) ->
  $scope.consommations = consommations
