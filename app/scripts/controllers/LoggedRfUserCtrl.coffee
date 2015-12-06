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
    order: '-login',
    limit: 10,
    page: 1

  success = (users) ->
    $scope.total = users.count
    $scope.users = users.users

  getUsers = ->
    limit = $scope.query.limit
    skip = limit * ($scope.query.page - 1)

    params =
      limit: limit
      skip: skip

    unless not $scope.search? or $scope.search.length <= 2
      params.search = $scope.search

    $http.get '/api/user', params: params
    .success success

  $scope.$watch 'search', (value) ->
    getUsers()

  $scope.searchFunc = (predicate) ->
    $scope.filter = predicate
    console.log "$scope.search", predicate
    getUsers()

  $scope.onOrderChange = (order) ->
    console.log "onOrderChange", order


  $scope.onPaginationChange = (page, limit) ->
    console.log "onPaginationChange", page, limit
    getUsers()

  $scope.click = ->
    console.log "click !!"
