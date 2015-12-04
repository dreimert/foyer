angular.module "ardoise.controllers"
.controller "LoggedCtrl", ($scope, $state, $window, UserService, LieuService) ->
  $scope.userService = UserService
  $scope.user = UserService.user
  $scope.lieu = LieuService.getLieu().value

  $scope.back = () ->
    $state.go "logged.accueil"

  $scope.signOut = ->
    $scope.userService.signOut()
