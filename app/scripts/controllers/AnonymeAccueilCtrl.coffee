angular = require 'angular'

angular.module "ardoise.controllers"
.controller "AnonymeAccueilCtrl",
  ($scope, $http, $state, $mdToast, consommables, lieu) ->
    $scope.consommations = []
    $scope.consommables = consommables
    $scope.disabled = false

    $scope.payer = (sum) ->
      $scope.disabled = true

      $http.post "api/anonyme/consommation/#{lieu.value}",
        consommations: $scope.consommations
      .success (data) ->
        $state.go "anonyme.paiement", montant: data.montant
      .error (data) ->
        $mdToast.show(
          $mdToast.simple()
          .content('Une erreur est survenu lors de la temtative de payement')
          .hideDelay(10000)
        )
        $scope.disabled = false
