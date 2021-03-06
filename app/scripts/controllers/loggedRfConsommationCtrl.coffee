angular = require 'angular'

angular.module "ardoise.controllers"
.controller "loggedRfConsommationCtrl", (
  $scope,
  $q,
  $http,
  consommations,
  total,
  lieu
) ->
  $scope.consommations = consommations
  $scope.total = total

  $scope.selected = []

  $scope.label =
    text: "Lignes par page"
    of: "sur"

  $scope.query =
    filter: '',
    order: '-date',
    limit: 10,
    page: 1

  success = (consommations) ->
    $scope.consommations = consommations

  getConsommations = (page, limit) ->
    $q (resolve, reject) ->
      skip = limit * page - limit
      $http.get "api/consommation/#{lieu.value}?limit=#{limit}&skip=#{skip}"
      .success (data) ->
        success data
        resolve data
      .error (data) ->
        reject data

  $scope.search = (predicate) ->
    $scope.filter = predicate
    console.log "$scope.search", predicate
    getConsommations($scope.query.page, $scope.query.limit)

  $scope.onOrderChange = (order) ->
    console.log "onOrderChange", order


  $scope.onPaginationChange = (page, limit) ->
    console.log "onPaginationChange", page, limit
    getConsommations(page, limit)
