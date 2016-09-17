angular = require 'angular'

angular.module "ardoise.controllers"
.controller "loggedRfLogCtrl",
  ($scope, $q, $http, UserService, $mdToast, logs, total) ->
    $scope.logs = logs
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

    success = (logs) ->
      $scope.logs = logs

    getLogs = (page, limit) ->
      $q (resolve, reject) ->
        skip = limit * page - limit
        $http.get "api/log?limit=#{limit}&skip=#{skip}"
        .success (data) ->
          success data
          resolve data
        .error (data) ->
          reject data

    $scope.search = (predicate) ->
      $scope.filter = predicate
      console.log "$scope.search", predicate
      getLogs($scope.query.page, $scope.query.limit)

    $scope.onOrderChange = (order) ->
      console.log "onOrderChange", order


    $scope.onPaginationChange = (page, limit) ->
      console.log "onPaginationChange", page, limit
      getLogs(page, limit)
