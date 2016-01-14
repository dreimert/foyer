angular.module "ardoise.controllers"
.controller "loggedRfFrigoCtrl", (
  $scope,
  $q,
  $http,
  consommations,
  total
) ->
  $scope.consommations = consommations
  $scope.total = total

  $scope.selected = []

  $scope.label =
    text: "Lignes par page"
    of: "sur"

  $scope.query =
    filter: '',
    order: 'nom',
    limit: 10,
    page: 1

  success = (consommations) ->
    $scope.consommations = consommations

  getConsommations = (page, limit, order) ->
    $q (resolve, reject) ->
      skip = limit * page - limit
      search = ""
      if $scope.query.filter
        search = "&search=#{$scope.query.filter}"

      $http.get "api/frigo?limit=#{limit}&skip=#{skip}&order=#{order}#{search}"
      .success (data) ->
        success data
        resolve data
      .error (data) ->
        reject data

  $scope.search = () ->
    console.log "search", $scope.query.filter
    getConsommations($scope.query.page, $scope.query.limit, $scope.query.order)

  $scope.onOrderChange = (order) ->
    console.log "onOrderChange", order
    getConsommations($scope.query.page, $scope.query.limit, order)

  $scope.onPaginationChange = (page, limit) ->
    console.log "onPaginationChange", page, limit
    getConsommations(page, limit, $scope.query.order)
