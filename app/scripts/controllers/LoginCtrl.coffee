angular.module "ardoise.controllers"
.controller "LoginCtrl", ($scope, $state, UserService, $mdToast) ->
  $scope.name = UserService.name or ""
  $scope.onFormSubmit = ->
    UserService.signIn($scope.login, $scope.password)
    .then () ->
      $state.go "logged.accueil"
    ,
      () ->
        $mdToast.show($mdToast.simple().content('Login ou mot de passe incorrect !'))
