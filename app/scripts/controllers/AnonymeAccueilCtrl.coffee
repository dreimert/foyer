angular.module "ardoise.controllers"
.controller "AnonymeAccueilCtrl", ($scope, $http, $state, $mdToast, LieuService, consommables) ->
  $scope.consommations = []
  $scope.consommables = consommables
  $scope.expand = true
  $scope.disabled = false

  $scope.payer = (sum) ->
    $scope.expand = false
    $scope.disabled = true

    $http.post 'api/anonyme/consommation', consommations: $scope.consommations, lieu: LieuService.getLieu().value
    .success (data) ->
      $state.go "anonyme.paiement", montant: sum
    .error (data) ->
      $mdToast.show(
        $mdToast.simple()
        .content('Une erreur est survenu lors de la temtative de payement...')
        .hideDelay(10000)
      )
      $scope.expand = true
      $scope.disabled = false
