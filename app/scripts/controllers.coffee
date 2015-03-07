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

.controller "LoggedController", ($scope, $state, $window, UserService, $mdSidenav, TitleService) ->
    $scope.userService = UserService
    $scope.user = UserService.user

    $scope.getTitle = () ->
      TitleService.getTitle()

    $scope.backButton = () ->
      TitleService.showBackButton()

    $scope.back = () ->
      $state.go "logged.accueil"

    $scope.toggleSideNav = () ->
      $mdSidenav('left').toggle()

    $scope.signOut = ->
      $scope.userService.signOut()
    
.controller "LoggedAccueilController", ($scope, UserService, $mdToast, consommables, TitleService) ->
  TitleService.setTitle("#{UserService.user.nom} #{UserService.user.prenom} : #{UserService.user.montant}")
  $scope.consommations = []
  $scope.sum = 0

  computeSum = () ->
    sum = 0
    for conso in $scope.consommations
      sum += conso.prix * conso.quantity
    $scope.sum = sum

  $scope.displayAll = () ->
    unless $scope.conso?
      $scope.conso = {}
    $scope.conso.search = "."

  $scope.keyPress = (e) ->
    if $scope.conso?.search.length is 0 and e.charCode is 13
      $scope.payer()

  $scope.selected = (conso) ->
    if conso
      if (index = $scope.consommations.indexOf(conso)) isnt -1
        $scope.consommations[index].quantity++
      else
        conso.quantity = 1
        $scope.consommations.unshift conso
      computeSum()
      $scope.conso.search = ""
      $scope.conso.selected = null

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
    console.log "Payer #{$scope.sum.toFixed(2)} €"
    $scope.consommations = []
    computeSum()

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
