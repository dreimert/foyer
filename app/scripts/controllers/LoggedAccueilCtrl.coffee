angular.module "ardoise.controllers"
.controller "LoggedAccueilCtrl", ($scope, $http, UserService, $mdToast, consommables, TitleService) ->
  TitleService.setTitle("#{UserService.user.nom} #{UserService.user.prenom} : #{UserService.user.montant.toFixed(2)}")
  $scope.consommations = []
  $scope.sum = 0
  $scope.conso = {}

  $scope.$watchCollection 'consommations', ->
    computeSum()

  computeSum = () ->
    sum = 0
    for conso in $scope.consommations
      sum += conso.prix * conso.quantity
    $scope.sum = sum

  $scope.keyPress = (e) ->
    if $scope.conso?.search.length is 0 and e.charCode is 13
      $scope.payer()
    return

  $scope.selected = (conso) ->
    console.log "selected", conso
    if conso
      if (index = $scope.consommations.indexOf(conso)) isnt -1
        $scope.consommations[index].quantity++
      else
        conso.quantity = 1
        $scope.consommations.push conso
      computeSum()
      $scope.conso.selected = ""
      $scope.conso.search = ""

  $scope.search = (search) ->
    unless search
      return consommables
    consommables.filter (consommable) ->
      consommable.nom.match(new RegExp(search, "i"))

  $scope.add = (index) ->
    $scope.consommations[index].quantity++
    computeSum()

  $scope.supp = (index) ->
    $scope.consommations.splice index, 1
    computeSum()

  $scope.payer = () ->
    $http.post 'api/me/consommation', consommations: $scope.consommations
    .success (data) ->
      console.log data.montant
      UserService.user.montant = data.montant
      TitleService.setTitle("#{UserService.user.nom} #{UserService.user.prenom} : #{UserService.user.montant.toFixed(2)}")
      console.log "Payer #{$scope.sum.toFixed(2)} €"
      $scope.consommations = []
      computeSum()
    .error (data) ->
      console.error data
