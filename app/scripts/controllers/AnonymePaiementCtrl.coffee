angular.module "ardoise.controllers"
.controller "AnonymePaiementCtrl", ($scope, $timeout, $state) ->
  $scope.secondes = 10
  $scope.montant = $state.params.montant

  timeout = null

  rebour = ->
    timeout = $timeout ->
      if $scope.secondes is 1
        $scope.secondes = 0
        $state.go "login"
      else
        $scope.secondes--
        rebour()
    , 1000

  rebour()
