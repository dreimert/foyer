"use strict"

angular.module "ardoise.controllers", [
  "ui.router"
  "angularMoment"
]
.controller "LoginController", ($scope, $state, UserService, $mdToast) ->
  $scope.name = UserService.name or ""
  $scope.onFormSubmit = ->
    UserService.signIn($scope.login, $scope.password)
    .then () ->
      $state.go "logged.accueil"
    ,
      () ->
        $mdToast.show($mdToast.simple().content('Login ou mot de passe incorrect !'))

.controller "LoggedController", ($scope, $state, $window, UserService, TitleService) ->
    $scope.userService = UserService
    $scope.user = UserService.user

    $scope.getTitle = () ->
      TitleService.getTitle()

    $scope.backButton = () ->
      TitleService.showBackButton()

    $scope.back = () ->
      $state.go "logged.accueil"

    $scope.signOut = ->
      $scope.userService.signOut()

.controller "LoggedAccueilController", ($scope, $http, UserService, $mdToast, consommables, TitleService) ->
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
      if conso.ignore
        conso.ignore = false
        return

      conso.ignore = true
      if (index = $scope.consommations.indexOf(conso)) isnt -1
        $scope.consommations[index].quantity++
      else
        conso.quantity = 1
        $scope.consommations.push conso
      conso.selected = null
      computeSum()

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
      TitleService.setTitle("#{UserService.user.nom} #{UserService.user.prenom} : #{UserService.user.montant}")
      console.log "Payer #{$scope.sum.toFixed(2)} €"
      $scope.consommations = []
      computeSum()
    .error (data) ->
      console.error data

.controller "LoggedConsommationController", ($scope, UserService, $mdToast, consommations, TitleService) ->
  TitleService.setTitle("#{UserService.user.nom} #{UserService.user.prenom} : #{UserService.user.montant}")
  $scope.consommations = consommations

.controller "LoggedAuthController", ($scope, $state, UserService, $mdToast) ->
  $scope.onFormSubmit = ->
    UserService.loginRf($scope.password)
    .then () ->
      $state.go "logged.rf.user"
    ,
      () ->
        $mdToast.show($mdToast.simple().content('mot de passe incorrect !'))

.controller "LoggedRfUserController", ($scope, $http, TitleService) ->
  TitleService.setTitle("Accueil")
  $scope.$watch 'search', (value) ->
    if not value? or value.length <= 2
      $scope.results = []
    else
      $http.get '/api/user', params: {search: value}
      .success (data) ->
        $scope.results = data

.controller "LoggedRfUserDetailController", ($scope, user, TitleService) ->
  TitleService.setTitle("#{user.prenom} #{user.nom}", true)
  $scope.personne = user

.controller "loggedRfConsommationController", ($scope, TitleService, consommations) ->
  TitleService.setTitle("Dernière consommation")
  $scope.consommations = consommations
