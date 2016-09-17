angular = require 'angular'

angular.module "ardoise.controllers"
.controller "LoggedRfUserCtrl", (
  $scope,
  $q,
  $http
) ->
  $scope.users = []
  $scope.total = 0
  $scope.selected = []
  $scope.label =
    text: "Utilisateur par page"
    of: "sur"

  $scope.query =
    filter: '',
    order: 'login',
    limit: 10,
    page: 1

  success = (users) ->
    $scope.total = users.count
    $scope.users = users.users

  getUsers = (page, limit, order) ->
    $q (resolve, reject) ->
      limit = limit
      skip = limit * (page - 1)

      params =
        limit: limit
        skip: skip
        order: order

      unless not $scope.query.filter? or $scope.query.filter.length < 2
        params.search = $scope.query.filter

      $http.get 'api/user', params: params
      .success (data) ->
        success data
        resolve data
      .error (data) ->
        reject data

  getUsers($scope.query.page, $scope.query.limit, $scope.query.order)

  $scope.search = () ->
    console.log "search", $scope.query.filter
    getUsers($scope.query.page, $scope.query.limit, $scope.query.order)

  $scope.onOrderChange = (order) ->
    console.log "onOrderChange", order
    getUsers($scope.query.page, $scope.query.limit, order)

  $scope.onPaginationChange = (page, limit) ->
    console.log "onPaginationChange", page, limit
    getUsers(page, limit, $scope.query.order)
