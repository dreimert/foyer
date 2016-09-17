angular = require 'angular'

angular.module "ardoise.controllers"
.controller "LoggedRfCreateUserCtrl", ($scope, $http) ->
  $scope.departements = [
    "Informatique"
    "Mathématiques"
    "Biologie"
    "Geologie"
    "Physique"
    "Chimie"
    "Arts"
    "Langues, littératures et civilisation étrangères"
    "Lettres"
    "Sciences humaines"
    "Sciences sociales"
    "Autre"
  ]
  date = new Date()
  $scope.user =
    promo: if date.getMonth() >= 8 then date.getFullYear() else date.getFullYear() - 1

  calculLoginAndMail = ->
    prenom = ($scope.user.prenom or "").toLowerCase()
    nom    = ($scope.user.nom or "").toLowerCase()
    if prenom[0]?
      $scope.user.login = prenom[0] + nom
    $scope.user.email = "#{prenom}.#{nom}@ens-lyon.fr"

  $scope.$watch "user.prenom", calculLoginAndMail
  $scope.$watch "user.nom", calculLoginAndMail

  $scope.onFormSubmit = ->
    console.log "user", $scope.user
