angular.module "ardoise.controllers"
.controller "LoggedCtrl", ($scope, $state, $window, UserService, TitleService) ->
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
