angular.module "ardoise.controllers"
.controller "LoggedConsommationCtrl",
  ($scope, $q, $http, UserService, $mdToast, consommations, total) ->
    $scope.consommations = consommations
    console.log "total", JSON.stringify total
    $scope.total = total

    $scope.selected = []

    $scope.query =
      filter: '',
      order: '-date',
      limit: 10,
      page: 1

    success = (consommations) ->
      console.log "success:consommations", consommations
      $scope.consommations = consommations

    getConsommations = ->
      $q (resolve, reject) ->
        limit = $scope.query.limit
        skip = limit * ($scope.query.page - 1)
        $http.get "/api/me/consommation?limit=#{limit}&skip=#{skip}"
        .success (data) ->
          success data
          resolve data
        .error (data) ->
          reject data

    $scope.search = (predicate) ->
      $scope.filter = predicate
      #$scope.deferred = $nutrition.desserts.get($scope.query, success).$promise;
      console.log "$scope.search", predicate
      getConsommations()

    $scope.onOrderChange = (order) ->
      #return $nutrition.desserts.get($scope.query, success).$promise
      console.log "onOrderChange", order


    $scope.onPaginationChange = (page, limit) ->
      #return $nutrition.desserts.get($scope.query, success).$promise
      console.log "onPaginationChange", page, limit
      getConsommations()
