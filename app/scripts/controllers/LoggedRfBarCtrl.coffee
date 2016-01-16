angular.module "ardoise.controllers"
.controller "LoggedRfBarCtrl", (
  $scope
  $q
  $http
  $mdToast
  consommables
  lieu
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

    $http.post "api/consommation/#{lieu.value}",
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

  $scope.getUsers = (search = "") ->
    limit = 10
    skip = 0

    params =
      limit: 10
      skip: 0
      order: 'login'

    if search.length >= 2
      params.search = search

    $http.get 'api/user', params: params
    .then (res) ->
      res.data.users.map (user) ->
        user.display = "#{user.prenom} #{user.nom} (#{user.login}) : #{user.montant} €"
        user
