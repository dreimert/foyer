angular.module "ardoise.controllers"
.controller "LoggedDeconnexionCtrl", ($scope, $timeout, UserService) ->
  $scope.solde = UserService.user.montant.toFixed(2)
  $scope.secondes = 3

  timeout = null

  rebour = ->
    timeout = $timeout ->
      if $scope.secondes is 1
        $scope.secondes = 0
        UserService.signOut()
      else
        $scope.secondes--
        rebour()
    , 1000

  rebour()
