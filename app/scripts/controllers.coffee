"use strict"

angular.module "aae.controllers", [
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
  TitleService.setTitle("Dernière consommation", true)
  $scope.consommations = consommations
