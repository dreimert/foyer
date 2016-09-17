angular = require 'angular'

angular.module "ardoise.directives"
.directive "selectConsommation", () ->
  restrict: 'E'
  scope:
    consommables: '='
    consommations: "="
    disabled: '='
    payer: '='
    focus: '='
  templateUrl: 'directive.selectConsommation.jade'
  controller: ($scope) ->
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
      if conso
        if (index = $scope.consommations.indexOf(conso)) isnt -1
          $scope.consommations[index].quantity++
        else
          conso.quantity = 1
          #$scope.consommations.push conso
        computeSum()

    $scope.search = (search) ->
      unless search
        return $scope.consommables
      $scope.consommables.filter (consommable) ->
        consommable.nom.match(new RegExp(search, "i"))

    $scope.add = (index) ->
      $scope.consommations[index].quantity++
      computeSum()

    $scope.supp = (index) ->
      $scope.consommations.splice index, 1
      computeSum()

    $scope.submit = ->
      $scope.payer($scope.sum)
