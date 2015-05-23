angular.module "ardoise.controllers"
.controller "LoginCtrl", ($scope, $state, $mdToast, UserService) ->
  $scope.lieux = [
    name: "Foyer"
    value: "foyer"
  ,
    name: "Kfet"
    value: "kfet"
  ]
  $scope.name = UserService.name or ""
  $scope.lieu = "foyer"
  for lieu in $scope.lieux when lieu.value is $state.params.lieu.toLowerCase()
    $scope.lieu = lieu.value

  console.log $state
  $scope.onFormSubmit = ->
    UserService.signIn($scope.login, $scope.password, $scope.lieu)
    .then () ->
      $state.go "logged.accueil"
    ,
      () ->
        $mdToast.show($mdToast.simple().content('Login ou mot de passe incorrect !'))
