angular.module "ardoise.controllers"
.controller "LoggedCtrl", ($scope, $state, $window, UserService) ->
  $scope.userService = UserService
  $scope.user = UserService.user

  $scope.back = () ->
    $state.go "logged.accueil"

  $scope.signOut = ->
    $scope.userService.signOut()
