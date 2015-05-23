angular.module "ardoise.controllers"
.controller "LoggedRfUserDetailCtrl", ($scope, user, TitleService) ->
  TitleService.setTitle("#{user.prenom} #{user.nom}", true)
  $scope.personne = user
