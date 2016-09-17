angular = require 'angular'

angular.module "ardoise.controllers"
.controller "LoggedAccueilCtrl",
  ($scope, $http, $state, $mdToast, UserService, consommables) ->
    $scope.consommations = []
    $scope.consommables = consommables
    $scope.disabled = false

    $scope.payer = (sum) ->
      $scope.disabled = true

      $http.post 'api/me/consommation',
        consommations: $scope.consommations
      .success (data) ->
        UserService.user.montant = data.montant
        $state.go "logged.deconnexion"
      .error (data) ->
        $mdToast.show(
          $mdToast.simple()
          .content('Une erreur est survenu lors de la temtative de payement...')
          .hideDelay(10000)
        )
        $scope.disabled = false
