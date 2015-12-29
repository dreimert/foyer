angular.module "ardoise.controllers"
.controller "LoggedRfBarCtrl", (
  $scope
  $q
  $http
  $mdToast
  consommables
) ->
  $scope.consommables = consommables
  $scope.consommations = []
  $scope.selected = {}
  $scope.disabled = false

  $scope.payer = (sum) ->
    $scope.disabled = true

    unless $scope.selected.user
      $mdToast.show(
        $mdToast.simple()
        .content("Vous n'avez pas selectionné d'utilisateur...")
        .hideDelay(10000)
      )
      console.log "no selected user"
      return

    $http.post 'api/consommation',
      consommations: $scope.consommations
      user: $scope.selected.user
    .success (data) ->
      $mdToast.show(
        $mdToast.simple()
        .content('Paiement effectué.')
        .hideDelay(5000)
      )
      $scope.selected.user = undefined
      $scope.search = ''
      $scope.consommations = []
      $scope.disabled = false
    .error (data) ->
      $mdToast.show(
        $mdToast.simple()
        .content('Une erreur est survenu lors de la temtative de payement...')
        .hideDelay(10000)
      )
      $scope.disabled = false

  getUsers = ->
    limit = 10
    skip = 0

    params =
      limit: 10
      skip: 0
      order: 'login'

    unless not $scope.search? or $scope.search.length <= 2
      params.search = $scope.search

    $http.get '/api/user', params: params
    .success (users) ->
      $scope.users = users.users.map (user) ->
        user.display = "#{user.prenom} #{user.nom} (#{user.login}) : #{user.montant} €"
        user

  $scope.$watch 'search', (value) ->
    getUsers()
